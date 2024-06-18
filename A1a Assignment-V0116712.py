#!/usr/bin/env python
# coding: utf-8

# In[5]:


import os, pandas as pd, numpy as np


# In[6]:


os.chdir("‪C:\\Users\\HP\\Downloads")


# In[7]:


df=pd.read_csv("NSSO68.csv",encoding="Latin-1", low_memory=False)


# In[8]:


df.head()


# In[13]:


HP = df[df['state_1']=="HP"]


# In[14]:


HP.isnull().sum().sort_values(ascending = False)


# In[15]:


df.columns


# In[16]:


HP_new = HP[['state_1', 'District', 'Sector','Region','State_Region','ricetotal_q','wheattotal_q','moong_q','Milktotal_q','chicken_q','bread_q','foodtotal_q','Beveragestotal_v','Meals_At_Home']]


# In[17]:


HP_new.isnull().sum().sort_values(ascending = False)


# In[18]:


HP_clean = HP_new.copy()


# In[19]:


HP_clean.loc[:, 'Meals_At_Home'] = HP_clean['Meals_At_Home'].fillna(HP_new['Meals_At_Home'].mean())


# In[20]:


HP_clean.isnull().any()


# In[21]:


# Outlier Checking
import matplotlib.pyplot as plt
# Assuming HP_clean is your DataFrame
plt.figure(figsize=(8, 6))
plt.boxplot(HP_clean['ricetotal_q'])
plt.xlabel('ricetotal_q')
plt.ylabel('Values')
plt.title('Boxplot of ricetotal_q')
plt.show()


# In[22]:


rice1 = HP_clean['ricetotal_q'].quantile(0.25)
rice2 = HP_clean['ricetotal_q'].quantile(0.75)
iqr_rice = rice2-rice1
up_limit = rice2 + 1.5*iqr_rice
low_limit = rice1 - 1.5*iqr_rice


# In[24]:


HP_clean=HP_new[(HP_new['ricetotal_q']<=up_limit)&(HP_new['ricetotal_q']>=low_limit)]


# In[25]:


plt.boxplot(HP_clean['ricetotal_q'])


# In[26]:


HP_clean['District'].unique()


# In[27]:


# Replace values in the 'Sector' column
HP_clean.loc[:,'Sector'] = HP_clean['Sector'].replace([1, 2], ['URBAN', 'RURAL'])


# In[28]:


#total consumption


# In[29]:


HP_clean.columns


# In[31]:


HP_clean.loc[:, 'total_consumption'] = HP_clean[['ricetotal_q', 'wheattotal_q', 'moong_q', 'Milktotal_q', 'chicken_q', 'bread_q', 'foodtotal_q', 'Beveragestotal_v']].sum(axis=1)


# In[32]:


HP_clean.head()


# In[33]:


HP_clean.groupby('Region').agg({'total_consumption':['std','mean','max','min']})


# In[35]:


HP_clean.groupby('District').agg({'total_consumption':['std','mean','max','min']})


# In[36]:


total_consumption_by_districtcode=HP_clean.groupby('District')['total_consumption'].sum()


# In[37]:


total_consumption_by_districtcode.sort_values(ascending=False).head(3)


# In[38]:


HP_clean.loc[:,"District"] = HP_clean.loc[:,"District"].replace({2: "Kangra", 5: "Mandi", 11: "Shimla", 6: "Hamirpur"})


# In[39]:


total_consumption_by_districtname=HP_clean.groupby('District')['total_consumption'].sum()


# In[40]:


total_consumption_by_districtname.sort_values(ascending=False).head(3)


# In[42]:


from statsmodels.stats import weightstats as stests


# In[43]:


rural=HP_clean[HP_clean['Sector']=="RURAL"]
urban=HP_clean[HP_clean['Sector']=="URBAN"]


# In[44]:


rural.head()


# In[45]:


urban.head()


# In[47]:


cons_rural=rural['total_consumption']
cons_urban=urban['total_consumption']


# In[48]:


z_statistic, p_value = stests.ztest(cons_rural, cons_urban)
# Print the z-score and p-value
print("Z-Score:", z_statistic)
print("P-Value:", p_value)


# In[ ]:




