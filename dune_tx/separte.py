import pandas as pd

# 文件名
input_file = "dune_tx/new_dune_results_2025.csv"  # 修改为你的文件名
base_name = input_file.split(".")[0]  # 获取文件名去掉扩展名

# 读取文件
df = pd.read_csv(input_file)

# 每个文件的条目数量
chunk_size = 100000

# 计算总条目数和需要拆分的文件数量
total_rows = len(df)
num_files = (total_rows // chunk_size) + (1 if total_rows % chunk_size != 0 else 0)

# 按 chunk_size 拆分并保存文件
for i in range(num_files):
    start_row = i * chunk_size
    end_row = min((i + 1) * chunk_size, total_rows)
    chunk = df.iloc[start_row:end_row]
    output_file = f"{base_name}_100k_{i+1}.csv"
    chunk.to_csv(output_file, index=False)
    print(f"生成文件: {output_file}")