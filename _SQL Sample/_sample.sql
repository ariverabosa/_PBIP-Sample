/*
Title: FactPrograms
Owner: Miguel
Created: 2/2/2026
Last Updated:
Purpose: Table of students per TermReportingYear, per term, per program 
Data source:
Tables/views used:
Filters:
Output fields:
How to validate:
Notes:
Change history: dd/mm/yyyy
- 2/2/2026: Created file
- 3/3/2026: Updated Indigenous status logic to use CD2 (Changing Dimension Type 2) as of term start date. The query now derives isIndigenous from DimStudent using person_pk and ValidFrom and ValidTo, treating missing history as No and no longer relying on the DimStudentKey stored in the fact table.
- 5/15/2026: Update to include ProgramType to filter by apprenticeship programs. 
*/

WITH Temp AS (
    SELECT 
        edw.person_id,
        ds.*
    FROM DimStudent ds
    JOIN edw.dbo.PERSON_EDWT edw
        ON edw.person_pk = ds.person_pk
),
ta AS (
    SELECT
        dt.TermReportingYear,
        dt.TermStartDate,
        pt.acad_programs_pk,
        pt.ReportGroup,
        pt.ProgramType,
        pt.CurrentFlag,
        pt.Program,
        CASE
            WHEN pt.Program IN ('IEETF-DP', 'PSIEJ-NA') THEN 'Int_NonVisa'
            ELSE 'Int_Visa'
        END AS International_Mix,
        t.person_pk,
        t.person_id,

        /* Convert YYYYMMDD int to real date */
        TRY_CONVERT(date, CONVERT(varchar(8), fsp.StudentProgramStartDate), 112)
            AS Program_StartDate,

        /* Convert end date, use today if 99991231 */
        CASE
            WHEN fsp.StudentProgramEndDate = 99991231
                THEN CAST(GETDATE() AS date)
            ELSE TRY_CONVERT(date, CONVERT(varchar(8), fsp.StudentProgramEndDate), 112)
        END AS Program_EndDate,

        /* Duration in days */
        DATEDIFF(
            DAY,
            TRY_CONVERT(date, CONVERT(varchar(8), fsp.StudentProgramStartDate), 112),
            CASE
                WHEN fsp.StudentProgramEndDate = 99991231
                    THEN CAST(GETDATE() AS date)
                ELSE TRY_CONVERT(date, CONVERT(varchar(8), fsp.StudentProgramEndDate), 112)
            END
        ) AS DaysBetween,

        fsp.*
    FROM FactStudentPrograms fsp
    JOIN DimTerm dt
        ON dt.DimTermKey = fsp.DimTermKey
    JOIN DimProgramTrack pt
        ON pt.DimProgramTrackKey = fsp.DimProgramTrackKey
    JOIN Temp t
        ON t.DimStudentKey = fsp.DimStudentKey
    WHERE dt.TermReportingYear >= 2018
)
SELECT
    ta.person_id,
    ta.person_pk,
    COALESCE(ds_asof.isIndigenous, 'No') AS isIndigenous,
    ta.acad_programs_pk,
    ta.ReportGroup,
    ta.CurrentFlag,
    ta.Program_StartDate,
    ta.Program_EndDate,
    ta.DaysBetween,
    ta.*
FROM ta
OUTER APPLY (
    SELECT TOP (1)
        ds2.isIndigenous
    FROM DimStudent ds2
    WHERE ds2.person_pk = ta.person_pk
      AND ta.TermStartDate >= ds2.ValidFrom
      AND ta.TermStartDate <  ds2.ValidTo
    ORDER BY ds2.ValidFrom DESC
) ds_asof
ORDER BY ta.TermStartDate;
