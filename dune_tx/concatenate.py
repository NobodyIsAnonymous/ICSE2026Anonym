import os
import pandas as pd

# 文件夹路径（替换为包含 CSV 文件的目录路径）
folder_path = "dune_tx/results/2025"  # 修改为你的文件夹路径
output_file = "dune_tx/merged_results_2025.csv"  # 合并后的文件名

folder_path = "dune_tx/merged"  # 修改为你的文件夹路径
output_file = "dune_tx/merged/total_merged.csv"  # 合并后的文件名

# 初始化一个空列表存储每个文件的DataFrame
dataframes = []

# 遍历文件夹中的所有文件
for file_name in os.listdir(folder_path):
    # 检查文件名是否符合要求
    if file_name.startswith("merged_results_") and file_name.endswith(".csv"):
        file_path = os.path.join(folder_path, file_name)
        try:
            df = pd.read_csv(file_path)
            dataframes.append(df)
        except Exception as e:
            print(f"读取文件 {file_name} 时出错: {e}")

# 合并所有DataFrame
if dataframes:
    merged_df = pd.concat(dataframes, ignore_index=True)
    merged_df.to_csv(output_file, index=False)
    print(f"合并完成，保存为 {output_file}")
else:
    print("没有找到符合条件的文件。")