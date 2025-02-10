import requests
import csv
from time import sleep
import jmespath

def replace_blanks(string_busca):
    # Substitui todos os espaços na string por '%20'
    return string_busca.replace(' ', '%20')


def get_item_id(products_brand):
    itens_search = []
    for product, brand_match in products_brand.items():
        # Adequa a string de busca
        string_busca = replace_blanks(product)
        url = f"https://api.mercadolibre.com/sites/MLB/search?q={string_busca}&limit=50"
        response = requests.get(url).json()
        for item in response.get('results', []):
            item_id = item.get('id')
            
            attributes = item.get('attributes', [])

            brand = 'Sem marca'

            # Itera a lista de atributos para achar a brand e comparar com a brand esperada do produto
            for attr in attributes:
                if attr.get("id") == "BRAND":
                    brand = attr.get("value_name", brand)
            
            if brand == brand_match:
                itens_search.append(item_id)
    
    return itens_search

def get_item_data(item_id):
    #Busca dados dos produtos
    url = f"https://api.mercadolibre.com/items/{item_id}"
    response = requests.get(url).json()

    results = {
        "item_id": response.get("id"),
        "title": response.get("title"),
        "brand": jmespath.search("attributes[?id=='BRAND'].value_name", response)[0],
        "category_id": response.get("category_id"),
        "domain_id": response.get("domain_id"),
        "price": response.get("price"),
        "base_price": response.get("base_price"),
        "original_price": response.get("original_price"),
        "currency": response.get("currency_id"),
        "condition": response.get("condition"),
        "seller_id": response.get("seller_id"),
        "free_shipping": response.get("shipping", {}).get("free_shipping"),
        "logistic_type": response.get("shipping", {}).get("logistic_type"),
        "available_quantity": response.get("available_quantity"),
        "listing_type_id": response.get("listing_type_id"), 
        "permalink": response.get("permalink"),
        "status": response.get("status"),
        "catalog_listing": response.get("catalog_listing"),
        "catalog_product_id": response.get("catalog_product_id"),
        "seller_city": jmespath.search("seller_address.city.name", response),
        "seller_state": jmespath.search("seller_address.state.name", response),
        "seller_country": jmespath.search("seller_address.country.name", response)
    }
    return results

def main():

    # Definir as marcas esperadas por produto para evitar produtos não aderentes/imitações na análise
    products_search = {
        "Google Home": "Google",
        "Chromecast": "Google",
        "Apple TV": "Apple",
        "Amazon Fire TV": "Amazon",
        "Amazon Fire Stick": "Amazon",
        "Xiaomi Mi Box": "Xiaomi",
        "Xiaomi Mi TV Stick": "Xiaomi",
        "Roku TV": "Roku",
        "Roku Stick": "Roku",
        "Roku Express": "Roku",
        "NVIDIA Shield": "NVIDIA"
    }

    all_results = []

    # Buscar ids dos produtos
    item_ids = get_item_id(products_search)
    # Remover ids duplicados
    item_ids = list(set(item_ids))

    # Para os IDs encontrados, buscar dados dos produtos
    for item_id in item_ids:
        results = get_item_data(item_id)
        all_results.append(results)
        sleep(1)  
        # Evitar rate-limiting


    # Escrever no csv usando DictWriter
    with open("item_data.csv", "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=all_results[0].keys())
        writer.writeheader()
        writer.writerows(all_results)

if __name__ == "__main__":
    main()