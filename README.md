# ICSE2026Anonym

Complementary Data for ICSE Research Paper: GenDetect
# GenDetect - Transaction Replay and Analysis Tool

A comprehensive tool for analyzing and matching DeFi transaction traces against known attack patterns.

## Overview

GenDetect provides functionality to:
- Match transaction traces against existing attack pattern rules
- Add new attack pattern rules to the database
- Batch process transactions for analysis
- Support multiple blockchain networks (mainnet, polygon, bsc, etc.)

## Prerequisites

### Required Dependencies

1. **Foundry Forge** - Ethereum development framework for smart contract testing and deployment
   
   **Installation:**
   ```bash
   # Install Foundry
   curl -L https://foundry.paradigm.xyz | bash
   
   # Restart your terminal or source your shell profile
   source ~/.bashrc  # or ~/.zshrc if using zsh
   
   # Install the latest version
   foundryup
   ```

2. **Git Submodules** - Required for Solidity smart contract compilation

   This project uses `forge-std` (Foundry's standard library) for Solidity testing
   ```bash
   git submodule update --init --recursive
   ```
## Installation

### Step-by-Step Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/NobodyIsAnonymous/ICSE2026Anonym.git
   cd ICSE2026Anonym
   ```

2. **Initialize Git submodules** (Required for Solidity compilation)
   ```bash
   git submodule update --init --recursive
   ```
   *This downloads the `forge-std` library needed by the smart contract test files*

3. **Set up Python environment**
   
   **Option A: Using Conda (Recommended)**
   ```bash
   # Create conda environment
   conda env create -f environment.yml
   conda activate gendetect
   
   # Install additional dependencies
   pip install -r requirements.txt
   ```
   
   **Option B: Using pip + venv**
   ```bash
   # Create virtual environment
   python -m venv gendetect-env
   source gendetect-env/bin/activate  # On Windows: gendetect-env\Scripts\activate
   
   # Install dependencies
   pip install -r requirements.txt
   ```

4. **Configure environment variables**
   ```bash
   # Copy example configuration
   cp .env.example .env
   
   # Edit .env file with your API keys
   nano .env  # or use your preferred editor
   ```
   
   **Required API Keys:**
   - `OPENAI_API_KEY`: For GPT-based analysis
   - `ETHERSCAN_API_KEY`: For blockchain data access
   
   **⚠️ Performance Note:** The tool uses Infura API for trace retrieval. Analysis speed depends on API response time. For better performance, consider using a local full node.

5. **Verify installation**
   ```bash
   # Check all dependencies automatically
   python check_dependencies.py
   
   # Auto-install missing dependencies (if any)
   python check_dependencies.py --install
   
   # Test the main tool
   python src/tx_replayer.py -h
   ```

### Dependencies Overview

The project requires the following main categories of dependencies:

- **Core Data Science**: pandas, numpy, scikit-learn, scipy, matplotlib
- **Machine Learning**: sentence-transformers, tslearn, xgboost  
- **NLP & Text Processing**: python-Levenshtein
- **APIs**: openai, requests, pydantic
- **Blockchain Data**: dune-client, opensearch-py
- **Utilities**: tqdm, joblib

All dependencies are listed in `requirements.txt` with version specifications.

## Usage

### Transaction Replayer (`tx_replayer.py`)

The main tool for transaction analysis with command-line interface.

#### Basic Commands

##### 1. Match Transaction Trace
Match a transaction against existing attack pattern rules:

```bash
python src/tx_replayer.py match <tx_hash>
```

**Example:**
```bash
python src/tx_replayer.py match 0x1106418384414ed56cd7cbb9fedc66a02d39b663d580abc618f2d387348354ab
```

##### 2. Add New Attack Pattern Rule
Add a new attack pattern rule to the database:

```bash
python src/tx_replayer.py add-rule <tx_hash> <rule_name>
```

**Examples:**
```bash
python src/tx_replayer.py add-rule 0x1106418384414ed56cd7cbb9fedc66a02d39b663d580abc618f2d387348354ab "New_Rule"
python src/tx_replayer.py add-rule 0xdef456... "Reentrancy_Exploit"
python src/tx_replayer.py add-rule 0x789abc... "Price_Manipulation"
```

#### Help Commands

```bash
# General help
python src/tx_replayer.py -h

# Help for specific commands
python src/tx_replayer.py match -h
python src/tx_replayer.py add-rule -h
python src/tx_replayer.py batch -h
```

### Example Workflows

#### 1. Analyze a Suspicious Transaction
```bash
# Step 1: Match against known patterns
python src/tx_replayer.py match 0x1106418384414ed56cd7cbb9fedc66a02d39b663d580abc618f2d387348354ab

# Step 2: If it's a new attack pattern, add it as a rule
python src/tx_replayer.py add-rule 0x1106418384414ed56cd7cbb9fedc66a02d39b663d580abc618f2d387348354ab "New_Attack_Pattern"
```


## File Structure

```
├── src/
│   ├── tx_replayer.py          # Main transaction replay tool
│   ├── tx_runner.py            # Transaction parsing utilities
│   ├── es_api.py              # ElasticSearch API interface
├── data_rules_related/        # Attack pattern rules and ML models
└── README.md                  # This file
```

## Important Notes & Limitations

### Performance Considerations
- **API Performance**: This tool uses Infura API for blockchain trace retrieval. Analysis speed heavily depends on API response time
- **Performance Optimization**: Using a local full node instead of Infura will significantly improve performance
- **Rate Limits**: Be mindful of API rate limits when processing large batches of transactions

### Data Availability  
- **Classification Dataset**: The labeled dataset used for attack pattern classification contains proprietary data from partner companies and cannot be included in this open-source release
- **Future Availability**: A processed/anonymized version of the classification dataset may be released after appropriate encryption and privacy protection measures

### Usage Guidelines
- Transaction hashes should be complete (with 0x prefix)
- Rule names should be descriptive and follow naming conventions  
- Results are saved as CSV files in the specified output directory
- Please respect API usage limits and avoid excessive requests

## Acknowledgments

### Data Sources
- **Attack Patterns**: Our attack rule database is built upon the comprehensive DeFi attack dataset from [DeFiHackLabs](https://github.com/SunWeb3Sec/DeFiHackLabs)
- **Transaction Data**: Blockchain transaction traces are retrieved via Infura API infrastructure

### Special Thanks
- **DeFiHackLabs Team**: For providing an excellent open-source collection of DeFi attack vectors and PoCs that serve as the foundation for our attack pattern analysis
- **Foundry Team**: For the robust smart contract testing framework used throughout this project

## License & Citation

This project is part of the research submitted to ICSE 2026. If you use this tool or dataset in your research, please cite our paper accordingly.

---

**⚠️ Disclaimer**: This tool is for research and educational purposes only. The authors are not responsible for any misuse of the provided attack detection capabilities.

