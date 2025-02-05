# README: Biomarker Analysis for Dual Diagnosis in SUD and ADHD

## 1. Project Overview
- **Title:** Exploratory Study of Plasma Acylglycerols and Acylethanolamides Dysregulation in Substance Use and Attention Deficit Hyperactivity Disorder: Implications for Novel Biomarkers in Dual Diagnosis
- **Objective:** This study investigates dysregulation of endocannabinoid lipids (acylglycerols and acylethanolamides) in patients with Substance Use Disorders (SUD) and comorbid ADHD. The aim is to identify potential biomarkers that could improve patient stratification and inform treatment strategies.
- **Population:**
  - 333 abstinent SUD patients
  - 136 healthy controls
  - SUD group further divided based on ADHD comorbidity.
- **Methods:**
  - Plasma lipid quantification using HPLC-MS.
  - Machine learning models (Elastic Net) for biomarker selection and classification.

## 2. Author and Affiliation
- **Bioinformatics Analysis Author:** Julia Verheul-Campos
- **Affiliation:** Instituto de Investigación Biomédica de Málaga y Plataforma en Nanomedicina (IBIMA), Málaga, Spain.
- **Correspondence:** Main contacts for the study: verheuljulia@gmail.com, javier.pavon@ibima.eu and fernando.rodriguez@ibima.eu.

## 3. Data Sources
- **Origin:** Data originates from a multicenter Spanish cohort recruited from outpatient treatment programs for alcohol and cocaine addiction.
- **Variables:**
  - **Dependent Variable:** SUD group classification (Control, SUD, SUD+ADHD).
    - **Covariable:** BMI.
  - **Independent Variables:** Plasma concentrations of 12 lipids (2-AG, 2-LG, 2-OG, AEA, DEA, DGLEA, DHEA, LEA, OEA, PEA, POEA, SEA).


## 4. Running the Analysis
### 4.1 Steps to Execute
1. Place the biomarker datasets (`modelo1.xlsx`, `modelo2.xlsx`) in the working directory.
2. Run the `biomarker_analysis.R` script.
3. Review output results in `results_model_X.txt`.

### 4.2 Expected Outputs
- Models achieving an accuracy > 65% are stored in text files.
- Best hyperparameters and selected coefficients are saved.
- AUC and accuracy scores are reported for each model.

## 5. Ethical Considerations
- **Ethical Approval:** Approved by the Andalusian Regional Ethics Committee.
- **Confidentiality:** All participant data are anonymized following GDPR regulations.





