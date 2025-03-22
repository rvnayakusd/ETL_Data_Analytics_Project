##Importing libraries
import kaggle
import pandas as pd
import sqlalchemy as sal
import  pyodbc 

##KAggle APi activation and extracting data
# kaggle.api.authenticate()
# kaggle.api.dataset_download_files('ankitbansal06/retail-orders', path='.', unzip=True)

##Read data from csv file and handle null values
df = pd.read_csv("orders.csv")
print(df.head(10))

#Rename column names 
df.columns = df.columns.str.lower()
#print(df.columns)
df.columns = df.columns.str.replace(' ','_')
#print(df.columns)


#Derive new columns discount, sale price and profit
df['discount'] = df['list_price']*df['discount_percent']*.01
df['sales_price'] = df['list_price'] - df['discount']
df['profit'] = df['sales_price'] - df['cost_price']

#convert order date from object dataa type to datetime
df['order_date'] = pd.to_datetime(df['order_date'], format = "%Y-%m-%d")

#drop cost_price, list_price and discount percent columns
df.drop(columns=['list_price', 'cost_price' , 'discount_percent'], inplace=True)

#load data into sql server using option

engine = sal.create_engine("mssql+pyodbc://Popeye\\SQLEXPRESS02/master?driver=ODBC+Driver+17+for+SQL+Server")

conn=engine.connect()

#load the data into sql server using append option
df.to_sql('df_order', con=conn, index=False, if_exists= 'append') 