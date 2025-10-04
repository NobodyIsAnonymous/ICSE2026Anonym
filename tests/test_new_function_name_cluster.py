from src.new_function_name_cluster import classify_new_function_names, read_data

def test_classify_new_function_names():
    clusters, remaining_non_cluster, unique_non_cluster, model, centroids = read_data('final_classified_functions.csv')
    assert classify_new_function_names('test', clusters, remaining_non_cluster, unique_non_cluster, model, centroids) == ('Common', 'test')
    assert classify_new_function_names('callback', clusters, remaining_non_cluster, unique_non_cluster, model, centroids) == ('Common', 'callback')
    assert classify_new_function_names('call', clusters, remaining_non_cluster, unique_non_cluster, model, centroids) == ('Unique', 'call')
    assert classify_new_function_names('back', clusters, remaining_non_cluster, unique_non_cluster, model, centroids) == ('Unique', 'back')
    assert classify_new_function_names('price', clusters, remaining_non_cluster, unique_non_cluster, model, centroids) == ('Unique', 'price')
    assert classify_new_function_names('checkpoint', clusters, remaining_non_cluster, unique_non_cluster, model, centroids) == ('Unique', 'checkpoint')
    assert classify_new_function_names('bind', clusters, remaining_non_cluster, unique_non_cluster, model, centroids) == ('Cluster', 'Common Cluster 9')
    assert classify_new_function_names('quoteExactInput', clusters, remaining_non_cluster, unique_non_cluster, model, centroids) == ('Cluster', 'Unique Cluster 13')
    assert classify_new_function_names('reentrant', clusters, remaining_non_cluster, unique_non_cluster, model, centroids) == ('Cluster', 'Unique Cluster 8')