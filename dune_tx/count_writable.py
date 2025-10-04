# 解析提供的函数名称列表并统计非 read-only (view) 函数的数量
import pandas as pd


# 定义 read-only (view) 相关的关键词
view_keywords = {
    "get", "fetch", "view", "check", "query", "balanceOf", "totalSupply", "rate", 
    "price", "is", "has", "current", "count", "tally", "index", "status", "info", 
    "estimate", "simulate", "calculate", "account"
}

financial_keywords = {"swap", "mint", "burn", "transfer", "deposit", "withdraw", "claim", "create", "destroy", "sell", "buy", "stake", "redeem", "borrow", "lend", "leverage", "liquidate" }

# read data from "functions_count.csv"
dataframe = pd.read_csv("./data_statistics_related/function_count.csv")
# read function names whose count is 1
functions = dataframe[dataframe["Count"] == 1]["Function"].tolist()
print(len(functions))
# 统计非 read-only (view) 函数
non_view_functions = [
    func for func in functions if not any(func.lower().startswith(v) for v in view_keywords)
]

confirmed_non_view_functions = [func for func in non_view_functions if any(func.lower().startswith(v) for v in financial_keywords)]

# 计算数量
non_view_function_count = len(non_view_functions)
confirmed_non_view_function_count = len(confirmed_non_view_functions)
# 返回统计结果
print(non_view_function_count)
print(confirmed_non_view_function_count)