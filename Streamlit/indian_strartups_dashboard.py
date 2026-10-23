import streamlit as st
import  pandas as pd

df = pd.read_csv('startup_funding.csv')

st.sidebar.title("Indian StartUp Analysis")
option = st.sidebar.selectbox('Select one', ['Overall Analysis', 'StartUp', 'Investor'])

if option == 'Overall Analysis':
    st.title('Overall Analysis')
elif option == 'StartUp':
    st.title('StartUp')
    start_up = st.sidebar.selectbox('Select StartUp', sorted(df['Startup Name'].unique().tolist()))

else:
    st.title('Investor')
    investor = st.sidebar.selectbox('Select Investor', sorted(df['Investors Name'].unique().tolist()))
