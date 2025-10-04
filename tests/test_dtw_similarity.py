from src.dtw_similarity import embed_sequence, calculate_dtw_distance, load_data
import pandas as pd
df = load_data('encoded_trace.csv')
df_no_loop = load_data('noloop_encoded_trace.csv')

def test_data():
    assert len(df) == 530
    assert df['id'][0] == 'SellToken'
    assert df['id'][1] == 'TIME'
    assert df['id'][len(df) - 1] == 'ZABU'
    
def test_embed_sequence():
    sequence = [('Common', 'set')]
    print(embed_sequence(sequence))
    
def test_dtw_distance():
    df = pd.read_csv('dtw_similarity.csv')
    filtered_df = df[df["distance"] > 0][df["trace_id_1"]!="HundredFinance"].nsmallest(20, "distance")
    print(filtered_df)