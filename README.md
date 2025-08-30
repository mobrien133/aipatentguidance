# Alice in Wonderland: AI Patent Guidance Analysis 🐇

[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/release/python-390/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Project Status: Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

This repository contains the software and analysis for the econometric research project, "Alice in Wonderland: How AI Guidance Changes Patent Prosecution Through the Looking Glass." The project conducts a quasi-experimental analysis of the USPTO's July 17, 2024, guidance on patent subject matter eligibility for Artificial Intelligence inventions.

## 📖 Table of Contents
* [Project Abstract](#-project-abstract)
* [Research Questions and Hypotheses](#-research-questions-and-hypotheses)
* [Methodology](#-methodology)
* [Data Sources](#-data-sources)
* [Repository Structure](#-repository-structure)
* [System Requirements and Installation](#-system-requirements-and-installation)
* [Execution Workflow](#-execution-workflow)
* [Citing This Research](#-citing-this-research)
* [License](#-license)
* [Contact](#-contact)

---
## 📄 Project Abstract
This paper provides a quasi-experimental econometric analysis of the U.S. Patent and Trademark Office's (USPTO) July 17, 2024, "Guidance Update on Patent Subject Matter Eligibility, Including on Artificial Intelligence". Using comprehensive administrative data queried directly from the USPTO's Open Data Portal (ODP) APIs, this study employs a difference-in-differences (DiD) methodology with two-way fixed effects to estimate the causal impact of the guidance. We construct a treatment group of AI-related patent applications and a control group of non-AI software patents to isolate the policy's effect. The findings are expected to show a substantial reduction in both §101 rejection rates and examination uncertainty, suggesting that targeted administrative guidance can effectively stabilize the patent examination landscape for emerging technologies.

---
## ❓ Research Questions and Hypotheses
This project tests three primary hypotheses based on economic theory and prior analyses of USPTO guidance.

1.  **Hypothesis 1 (Rejection Rates):** The 2024 AI Guidance led to a statistically significant decrease in the probability of a patent application in AI-related technologies receiving a §101 rejection during the first office action.
2.  **Hypothesis 2 (Examination Uncertainty):** The guidance led to a statistically significant decrease in the variance of §101 rejection rates among examiners within AI-related technology areas.
3.  **Hypothesis 3 (Firm Strategy):** Firms with significant AI patent portfolios increased their rate of new AI-related patent filings following the guidance.

---
## 🧪 Methodology
The core of this analysis is a **difference-in-differences (DiD)** model with **two-way (firm and time) fixed effects**. This quasi-experimental method allows us to isolate the causal impact of the 2024 AI Guidance by comparing the change in outcomes for AI patents (treatment group) to the change for non-AI software patents (control group) after the policy was implemented.

The primary model is specified as:
`Y_it = β₀ + δ(Treated_i × Post_t) + α_i + γ_t + ε_it`

Where:
- `Y_it` is the outcome variable (e.g., §101 rejection rate) for firm `i` in quarter `t`.
- `δ` is the DiD estimator, representing the causal effect of the guidance.
- `α_i` represents firm fixed effects, controlling for all stable, unobserved firm characteristics.
- `γ_t` represents time fixed effects, controlling for macro-level trends affecting all firms.

The analysis is supplemented with **Negative Binomial regression** for count data (patent filings) and **Quantile Regression** to analyze heterogeneous effects across the distribution of outcomes.

---
## 💾 Data Sources
This project uses administrative data obtained from the USPTO's Bulk Data Storage System (BDSS). Specifically, we use the "Patent Grant Full Text Data/XML" files, which contain detailed information for each granted patent.

While the original goal was to automate data collection via the USPTO's Open Data Portal (ODP) APIs, the current workflow relies on manually downloading the weekly XML files from the BDSS. Future work may revisit API-based collection to further automate and scale the data pipeline.rm_id`.

---
## 📂 Repository Structure
```
├── data/
│   ├── raw/                # Raw data downloaded from USPTO APIs
│   └── processed/          # Cleaned and processed panel dataset
│
├── notebooks/
│   └── exploratory_analysis.ipynb  # Jupyter notebook for EDA and assumption checks
│
├── results/
│   ├── figures/            # Generated plots (e.g., event study plot)
│   └── tables/             # Regression output tables
│
├── src/
│   ├── 01_parse_xml_data.py        # Script to parse XML files and classify patents
│   ├── 02_get_office_actions.py    # (Future) Script to download and parse office actions
│   ├── 03_build_panel.py           # (Future) Script to assemble the final firm-quarter panel
│   └── 04_run_analysis.py          # (Future) Script to run all econometric models
│
├── .gitignore              # Git ignore file
├── README.md               # This documentation file
└── requirements.txt        # Python package dependencies
```

---
## ⚙️ System Requirements and Installation

1.  **Python:** This project requires Python 3.9 or higher.
2.  USPTO Data: Manually download the "Patent Grant Full Text Data/XML" files from the [USPTO BDSS](https://bulkdata.uspto.gov/). Place the .xml files in the root directory.
3.  **Dependencies:** Clone the repository and install the required Python packages.
    ```bash
    git clone [https://github.com/](https://github.com/)[YourUsername]/alice-in-wonderland-ai-guidance.git
    cd alice-in-wonderland-ai-guidance
    pip install -r requirements.txt
    ```
---
## 🚀 Execution Workflow
The analysis is performed by running the Python scripts in the `/src` directory in numerical order. Each script is designed to be run from the root directory of the project.

1.  **Parse XML Data and Classify Patents:**
Place your downloaded USPTO .xml file (e.g., ipg240102.xml) in the project's root directory. Then, run the parsing script:
python src/01_parse_xml_data.py
This script performs the critical first step: it reads a raw USPTO XML file, extracts key metadata for each patent (application number, assignee, filing date, etc.), and applies a sophisticated ruleset to classify each patent into the 'AI' (treatment) or 'Control' group. The clean, classified data is saved to data/raw/.
    `python src/01_fetch_applications.py`
    *This script queries the USPTO API for all applications filed within the specified date range and saves the raw data to `data/raw/`.*

2.  **Get and Parse Office Actions:**
    `python src/03_get_office_actions.py`
    *This is a computationally intensive step. The script iterates through each application, downloads the first office action text, and parses it to determine if a §101 rejection was made.*

3.  **Build the Final Panel:**
    `python src/05_build_panel.py`
    *This script merges all intermediate datasets and aggregates the data to the firm-quarter level, saving the final analytical panel to `data/processed/`.*

4.  **Run Econometric Analysis:**
    `python src/06_run_analysis.py`
    *This script loads the final panel dataset and runs the DiD, Negative Binomial, and Quantile regression models. Results are saved to `results/tables/`.*

5.  **Generate Visualizations:**
    `python src/07_generate_visuals.py`
    *This script generates all figures for the paper, including the critical event study plot for the parallel trends assumption, and saves them to `results/figures/`.*

---
## ✒️ Citing This Research
If you use the code or findings from this project, please cite the author's work:
> O'Brien, Michael. (2025). "Alice in Wonderland: How AI Guidance Changes Patent Prosecution Through the Looking Glass." *Working Paper*.

---
## 📜 License
This project is licensed under the MIT License. See the `LICENSE` file for details.

---
## 📞 Contact
Michael O'Brien – mobrien133@gmail.com
