# Utah Assessment Data Expansion Research

## Package Status

**Current Version:** 0.1.0
**R-CMD-check:** PASS (0 errors, 0 warnings, 0 notes)
**Python Tests:** Not yet implemented
**pkgdown:** Not yet built

**Current Scope:** Enrollment data only (2014-2026)

---

## Assessment Data Availability

### Data Source
**Utah State Board of Education (USBE)**
- **Data Gateway:** https://datagateway.schools.utah.gov/
- **Assessment Resources:** https://schools.utah.gov/assessment/resources.php
- **Utah RISE Portal:** https://utahrise.org/
- **File Format:** Interactive web portal (potential CSV/Excel exports)

### Assessment Systems Available

#### Current Assessments (2019-Present)

**RISE (Readiness Improvement Success Empowerment)**
- **Grades:** 3-8
- **Subjects:**
  - English Language Arts (ELA)
  - Mathematics
  - Science
- **Years Available:** 2019-2024 (may have 2025 data available)
- **Data Access:** USBE Data Gateway

**Utah Aspire Plus**
- **Grades:** 9-10
- **Subjects:**
  - English
  - Mathematics
  - Reading
  - Science
- **Purpose:** Measures college and career readiness, provides predictive ACT scores
- **Years Available:** 2019-2024
- **Data Access:** USBE Data Gateway

**ACT**
- **Grade:** 11
- **Purpose:** College readiness assessment
- **Years Available:** Statewide administration (varies by year)
- **Note:** May be excluded per user instructions

**Acadience Reading** (formerly DIBELS)
- **Grades:** K-3
- **Purpose:** Early literacy benchmarking
- **Years Available:** Multiple years
- **Data Access:** USBE Data Gateway

#### Historical Assessments

**SAGE (Student Assessment of Growth and Excellence)**
- **Years:** 2014-2018
- **Grades:** 3-11 (varied by subject/grade)
- **Subjects:**
  - English Language Arts
  - Mathematics
  - Science
  - Writing (some years)
- **EOC Assessments:** Included End-of-Course exams in secondary subjects
- **Ended:** 2018 (contract expired, replaced by RISE and Utah Aspire Plus)

**Stanford Achievement Test (SAT9)**
- **Years:** 1990s-2004
- **Type:** Norm-referenced test
- **Purpose:** National comparison of student performance
- **Format:** Paper-based

---

## Historical Assessment Landscape

### Utah Assessment Evolution Timeline

#### 1990s-2004: Stanford Achievement Test Era
- **SAT9** administered statewide
- Norm-referenced assessment comparing Utah students to national peers
- Multiple subjects tested
- Paper-based format

#### 2004-2013: Transition Period
- **Early 2000s:** Utah participated in development of new assessments
- **2010-2012:** Initial participation in Smarter Balanced Consortium (helped design computer-adaptive assessments)
- **2013:** USBE directed development of SAGE assessment system

#### 2014-2018: SAGE Era
- **2014:** SAGE first administered
- **Subjects covered:**
  - Reading
  - Writing
  - Math
  - Science
- **Included EOC assessments** for secondary courses
- Computer-based testing
- **2018:** SAGE contract with American Institute for Research expired
- **June 2018:** Utah State Board of Education voted to replace SAGE

#### 2019-Present: RISE and Utah Aspire Plus Era
- **2019:** New assessments implemented
  - **RISE** for grades 3-8
  - **Utah Aspire Plus** for grades 9-10 (developed with Pearson)
- **Current system features:**
  - Computer-adaptive testing
  - Measures college and career readiness
  - Predictive ACT scores (Utah Aspire Plus)
  - Online administration

---

## Data Access Analysis

### USBE Data Gateway

**URL:** https://datagateway.schools.utah.gov/

**Description:** Interactive web portal providing public access to Utah education data including assessment results.

**Features:**
- Public access to school outcomes data
- Assessment results by school, district, and state levels
- Demographic subgroup breakdowns
- Privacy protection through statistical suppression

**Suppression Rules (per USBE documentation):**
- Subgroups with 10 or fewer students: recoded as "N<10"
- Percentage suppression varies by subgroup size:
  - 300+ students: ≥99% or ≤1%
  - 100-299 students: ≥98% or ≤2%
  - 40-99 students: ≥95% or ≤5%
  - 20-39 students: ≥90% or ≤10%
  - 10-19 students: ≥80% or ≤20%

**Data Export Capabilities:**
- Interactive dashboard (not static file downloads)
- May offer CSV/Excel export functionality (requires investigation)
- Potential API or programmatic access (uncertain - needs testing)

### Data Format Uncertainties

**Unknown Factors:**
1. **Programmatic Access:** Unknown if Data Gateway offers API or direct download URLs
2. **File Format:** Unclear if data can be exported as CSV/Excel in bulk
3. **Authentication:** Unknown if data access requires login or authentication
4. **Historical Data:** Unclear if SAGE data (2014-2018) is available through portal
5. **URL Patterns:** Unknown if predictable URLs exist for automated downloading

**Investigation Needed:**
1. Test Data Gateway for CSV/Excel export functionality
2. Check for API endpoints or bulk download options
3. Verify availability of historical SAGE data
4. Test if URLs follow predictable patterns
5. Assess authentication requirements

---

## Implementation Complexity

### Complexity Level: **UNKNOWN - REQUIRES INVESTIGATION**

#### Potential Challenges:

1. **Interactive Portal:**
   - Data Gateway appears to be interactive dashboard
   - May not offer direct file downloads
   - Could require browser automation (undesirable)

2. **Programmatic Access Uncertain:**
   - No clear API documentation
   - May require manual interaction
   - URL patterns unknown

3. **Historical Data Availability:**
   - SAGE data (2014-2018) availability unclear
   - May need to locate archived datasets
   - Potential format changes between SAGE and RISE

4. **Suppression Complexity:**
   - Complex suppression rules for privacy
   - Percentage intervals instead of exact values for small groups
   - "N<10" codes for small subgroups
   - Must handle suppressed values appropriately

5. **Data Structure:**
   - Multiple assessment systems (SAGE vs RISE vs Utah Aspire Plus)
   - Different grade spans for different assessments
   - EOC assessments may have different structure

#### Potential Advantages:

1. **Single Data Portal:**
   - All assessment data in one place
   - Consistent interface across years
   - Official USBE source

2. **Modern System:**
   - Data Gateway appears actively maintained
   - Current assessment data available
   - Regular updates

3. **Rich Demographics:**
   - Student group breakdowns available
   - Multiple disaggregation options
   - Consistent with enrollment data demographics

4. **No Federal Sources:**
   - State-level data directly from USBE
   - No federal aggregation or transformation

---

## Implementation Recommendations

### Phase 1: Data Access Investigation (CRITICAL FIRST STEP)

**Goal:** Determine if programmatic access to Utah assessment data is feasible

**Tasks:**
1. **Explore Data Gateway Interface:**
   - Navigate to https://datagateway.schools.utah.gov/
   - Check for "Download" or "Export" buttons
   - Test if CSV/Excel downloads are available
   - Look for API documentation or developer resources

2. **Test URL Patterns:**
   - Try to identify predictable URL patterns for downloads
   - Test if direct file links exist
   - Check for REST endpoints or similar

3. **Verify Historical Data:**
   - Search for SAGE data (2014-2018)
   - Check if archived datasets are available
   - Document data gaps

4. **Assess Authentication:**
   - Determine if login required for data access
   - Check for API keys or authentication tokens
   - Test public vs authenticated access

**Time Estimate:** 2-3 hours

**Decision Point:** After investigation, determine if automated access is feasible or if manual intervention will always be required

### Phase 2: Implementation Based on Findings

#### Scenario A: Direct Downloads Available

If Data Gateway offers CSV/Excel downloads with predictable URLs:

**Recommended Approach:** Implement similar to enrollment data

**Functions to Create:**
1. `get_raw_assessment(year, level, subject)` - Download assessment data
2. `process_assessment(raw_data)` - Process and standardize
3. `fetch_assessment(year, tidy = TRUE)` - User-facing function

**Estimated Effort:** 10-15 hours

#### Scenario B: Interactive Portal Only

If Data Gateway requires manual interaction:

**Recommended Approach:** Implement hybrid manual + automated

**Functions to Create:**
1. `import_local_assessment(path)` - Import manually downloaded files
2. `process_assessment(raw_data)` - Process and standardize
3. Document manual download process in vignette

**Estimated Effort:** 8-12 hours

**Documentation Requirements:**
- Step-by-step download guide with screenshots
- Instructions for navigating Data Gateway
- File naming conventions for local imports
- Example workflow for using `import_local_assessment()`

#### Scenario C: No Public Access

If no public data access exists:

**Recommended Approach:** Document data gap, recommend advocacy

**Actions:**
1. Document findings in EXPANSION.md
2. Contact USBE to request public data access
3. Suggest users contact USBE for assessment data needs
4. Monitor for future data access improvements

---

## Time Series Heuristics

### Major Breakpoints

1. **2018-2019:** SAGE → RISE/Utah Aspire Plus transition
   - Major format change
   - Different assessments (SAGE EOC vs Utah Aspire Plus)
   - Not directly comparable

2. **2020:** COVID-19 pandemic
   - Potential assessment disruptions
   - May have data quality issues
   - Possible waivers or modifications

3. **2014:** SAGE implementation
   - First year of SAGE
   - Transition from previous assessments
   - Potential baseline year issues

### Continuous Segments

- **2014-2018:** SAGE era (potential continuous time series)
- **2019-2024:** RISE/Utah Aspire Plus era (continuous time series)

### Data Gaps

- **Pre-2014:** Assessment data may not be readily accessible
- **2019-2020:** May have pandemic-related disruptions
- **SAGE vs RISE:** Not directly comparable due to different scales/assessments

---

## Schema Analysis

### Expected Data Structure (Based on USBE Documentation)

**Data Dimensions:**
- **Entity:** State, District (LEA), School
- **Grade:** K-12 (varies by assessment)
- **Subject:** ELA, Math, Science, Reading
- **Student Groups:** Race/ethnicity, economic status, EL, special education
- **Performance Levels:** Varies by assessment (SAGE vs RISE)

**SAGE Performance Levels (2014-2018):**
- Scale scores and proficiency levels
- Subject-specific performance categories
- EOC assessments may have different structure

**RISE Performance Levels (2019-present):**
- Proficiency levels (exact categories need verification)
- Scale scores
- Subject-specific performance categories

**Suppression Indicators:**
- "N<10" for small subgroups
- Percentage intervals (e.g., "≥95%", "≤5%")
- May require special handling

### Unknown Schema Elements

**Requires Investigation:**
1. Exact column names and structure
2. Performance level definitions and values
3. EOC assessment structure (if available)
4. Student group coding and categories
5. Year-over-year schema changes
6. File formats (CSV, Excel, etc.)

---

## Data Quality Considerations

### Known Issues

1. **Privacy Suppression:**
   - Complex suppression rules for small groups
   - Percentage intervals instead of exact values
   - "N<10" codes for small subgroups
   - Must handle suppressed values appropriately

2. **Assessment Transitions:**
   - SAGE → RISE transition (2018-19) not directly comparable
   - Different scales, performance levels, subject coverage
   - Break in time series continuity

3. **Pandemic Impact:**
   - Potential assessment disruptions in 2019-20
   - Participation rate variations
   - Data quality issues in pandemic years

4. **Small School/District Issues:**
   - Utah has many rural schools/districts
   - Small enrollments may lead to extensive suppression
   - Some entities may have no reportable data

### Recommended Validation

1. **Participation Rate Checks:**
   - Verify participation rates are reasonable (>90% ideally)
   - Flag years with low participation
   - Document pandemic-era issues

2. **Suppression Documentation:**
   - Clearly document suppression rules
   - Include suppression indicators in output
   - Provide guidance on handling suppressed values

3. **Cross-Level Validation:**
   - District sums should approximately equal state totals
   - School sums should approximately equal district totals
   - Allow for rounding differences and suppression

4. **Major Districts Present:**
   - Verify large districts present (Jordan, Alpine, Davis, Granite)
   - Check for reasonable student counts
   - Validate against enrollment totals

---

## Testing Strategy

### Investigation Tests (Phase 1)

1. **URL Accessibility:**
   - Test Data Gateway accessibility
   - Check for download/export functionality
   - Verify authentication requirements

2. **File Format Detection:**
   - Determine if CSV/Excel exports available
   - Test sample downloads
   - Document file structure

### Unit Tests (Phase 2 - If Implementation Proceeds)

1. **File Download:**
   - Verify successful downloads for available years
   - Test cache functionality
   - Handle download failures gracefully

2. **File Parsing:**
   - Verify readxl/readr can parse files
   - Test multiple years to detect schema changes
   - Handle different file formats

3. **Column Structure:**
   - Verify expected columns exist
   - Test for column name changes over time
   - Map columns to standard names

4. **Data Quality:**
   - No negative test counts where inappropriate
   - Proficiency percentages in valid ranges
   - Handle suppressed values appropriately
   - Major districts present

5. **Aggregation:**
   - State totals match sum of districts (approximately)
   - District totals match sum of schools (approximately)
   - Account for suppression in aggregation checks

6. **Fidelity:**
   - Tidy format preserves raw data
   - No rounding errors in tidying
   - Suppressed values handled correctly

---

## Next Steps

### Immediate Actions Required

1. **Investigate Data Gateway (CRITICAL):**
   - Spend 2-3 hours exploring data access options
   - Test for CSV/Excel export functionality
   - Document findings

2. **Check for SAGE Historical Data:**
   - Search for archived SAGE results (2014-2018)
   - Determine if historical data accessible
   - Document data gaps

3. **Assess Feasibility:**
   - Determine if automated access is possible
   - Decide between automated vs manual approach
   - Create implementation plan based on findings

### Implementation Decision Tree

**After Investigation:**

**If direct downloads available:**
- Proceed with automated implementation (Scenario A)
- Estimated effort: 10-15 hours
- Full automation possible

**If manual download required:**
- Implement hybrid approach (Scenario B)
- Estimated effort: 8-12 hours
- Clear documentation needed

**If no public access:**
- Document data gap
- Recommend advocacy for USBE to provide public data
- Monitor for future improvements

---

## References

### Official Sources
- [USBE Data Gateway](https://datagateway.schools.utah.gov/)
- [Utah RISE Portal](https://utahrise.org/)
- [USBE Assessment Resources](https://schools.utah.gov/assessment/resources.php)
- [USBE Assessment and Accountability](https://schools.utah.gov/assessment/index.php)

### Historical Documentation
- [The History of Assessment in Utah - Utah Legislature](https://le.utah.gov/interim/2016/pdf/00002856.pdf)
- [RISE Testing in Utah: Historical Overview](https://le.utah.gov/interim/2019/pdf/00003111.pdf)

### News and Analysis
- [Utah education board ends SAGE testing - KUTV](https://kutv.com/news/local/utah-education-board-ends-sage-testing)
- [Statewide SAGE exam to be replaced by two new tests - Park Record](https://www.parkrecord.com/2018/06/20/statewide-sage-exam-to-be-replaced-by-two-new-tests/)
- [Utah Aspire Plus Information](https://utah.mypearsonsupport.com/)

### Technical Reports
- [Utah Aspire Plus 2023-2024 Technical Report - USBE](https://schools.utah.gov/assessment/_assessment_/_resources_/_technical_reports_/23_UAPlus_TechnicalReport.pdf)
- [Acadience Reading Validity & Cutoff Scores for 3rd Grade RISE - UEPC](https://uepc.utah.edu/_resources/documents/uepc-acadience-rise-full-report.pdf)

---

**Last Updated:** 2025-01-11
**Research Status:** Complete - Data access investigation required
**Recommended Next Phase:** Investigate USBE Data Gateway for programmatic access options (2-3 hours)
**Critical Unknown:** Whether assessment data can be accessed programmatically or requires manual download
