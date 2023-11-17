import pandas as pd
import numpy as np

# Read in the data
df = pd.read_csv('/Users/devvratmungekar/Library/CloudStorage/OneDrive-Personal/Canada/Trent University/Sem-3/AMOD-5250-Data_Analytics_with_R/Project/superstore/Global Superstore Orders 2016.csv')

# Drop missing values
df = df.dropna()

# Drop unwanted columns
df = df.drop(['PostalCode'], axis=1)

df['OrderDate'] = pd.to_datetime(df['OrderDate'], format= '%Y-%m-%d')
df['ShipDate'] = pd.to_datetime(df['ShipDate'], format= '%Y-%m-%d')


df['Profit'] = df['Profit'].str.replace('$', '')
df["Profit"] = [float(str(i).replace(",", "")) for i in df["Profit"]]
df['Profit'] = df['Profit'].astype(float)

df['Sales'] = df['Sales'].str.replace('$', '')
df["Sales"] = [float(str(i).replace(",", "")) for i in df["Sales"]]
df['Sales'] = df['Sales'].astype(float)


print(df.head(5))
print(df.info())

# Write the cleaned data to a new file
df.to_csv('/Users/devvratmungekar/Library/CloudStorage/OneDrive-Personal/Canada/Trent University/Sem-3/AMOD-5250-Data_Analytics_with_R/Project/superstore/cleaned.csv', index=False)
