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


## Installation

1. Clone the repository
2. Install dependencies from `environment.yml`

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

##### 3. Batch Processing
Process multiple transactions using multi-processing:

```bash
# Start multi-process transaction replayer
python src/tx_replayer.py batch --multi-process-replayer

# Start multi-process ES data matcher
python src/tx_replayer.py batch --multi-process-es-matcher
```

#### Advanced Options

##### Custom Network and Directories
Specify different networks and output directories:

```bash
# Use Polygon network
python src/tx_replayer.py --network polygon --output-dir results/polygon/ match 0xabc123...

# Use BSC network with custom ES files
python src/tx_replayer.py --network bsc --es-files "dune_tx/2024/bsc_*.csv" --output-dir results/bsc/ match 0xdef456...

# Use custom ES data files pattern
python src/tx_replayer.py --es-files "dune_tx/2023/custom_*.csv" --output-dir custom_results/ add-rule 0x789abc... "Custom_Attack"
```

#### Available Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--es-files` | `dune_tx/2023/new_dune_results_*_100k_*.csv` | ES data file path pattern |
| `--output-dir` | `dune_tx/results/2023/` | Output directory for results |
| `--network` | `mainnet` | Network name (mainnet, polygon, bsc, etc.) |

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

#### 2. Process Multiple Networks
```bash
# Process mainnet transactions
python src/tx_replayer.py --network mainnet batch --multi-process-replayer

# Process polygon transactions
python src/tx_replayer.py --network polygon --es-files "dune_tx/polygon/*.csv" --output-dir results/polygon/ batch --multi-process-es-matcher
```

## File Structure

```
├── src/
│   ├── tx_replayer.py          # Main transaction replay tool
│   ├── tx_runner.py            # Transaction parsing utilities
│   ├── es_api.py              # ElasticSearch API interface
│   └── ...
├── dune_tx/                   # Transaction data files
│   ├── 2023/                  # 2023 transaction data
│   ├── 2024/                  # 2024 transaction data
│   └── results/               # Analysis results
├── data_rules_related/        # Attack pattern rules and ML models
└── README.md                  # This file
```

## Notes

- Always ensure ES database connection before running analysis
- Transaction hashes should be complete (with 0x prefix)
- Rule names should be descriptive and follow naming conventions
- Batch processing is recommended for large datasets
- Results are saved as CSV files in the specified output directory
