import  streamlit as st
import pandas as pd
import time

# ============ Text Utility ==========

st.title('Learning Streamlit')
st.header('With CapusX')
st.subheader('@Nitesh_Sir')
st.write('I start today learning streamlit and i love this.')

st.markdown(
    """
        #### Movies
        - Race 3
        - Race 2
        - Geeta Govindam
    """
)

st.code("""
def add(a,b):
    return a+b
        
print(add(1,4))    
""")

st.latex('x^2 + y^2 = 0')


# ============ Display Elements ==========

df = pd.DataFrame({
    'name' : ['Dalchand', 'Rohit', 'seeta', 'seema'],
    'marks' : [90, 89, 92, 89],
    'city' : ['Jaipur', 'Alwar', 'Sikar', 'Jaipur']
})

st.dataframe(df)

st.subheader('Metric Card')
st.metric(label='Income', value='60K', delta='5%', border=True, width=120)

st.json({
    'name' : ['Dalchand', 'Rohit', 'seeta', 'seema'],
    'marks' : [90, 89, 92, 89],
    'city' : ['Jaipur', 'Alwar', 'Sikar', 'Jaipur']
})


# ============ Display Media ==========

st.image('spendtrack.png')
st.video('spendtrack.webm')

# ============ Creating Layouts ==========

# sidebar
st.sidebar.title('SpendTrack')
st.sidebar.dataframe(df)

#columns
col1, col2 = st.columns(2)

with col1:
    st.metric(label='Income', value='60K', delta='5%', border=True, width=120)
with col2:
    st.metric(label='Spend', value='30K', delta='7%', border=True, width=120, delta_color='red')

# ============ Showing Status ==========

# Message
st.error('Login Failed! Try Again')
st.success('Login Successfully !')
st.warning('Week Passcode ')

# Progress Bar

bar = st.progress(0)

for i in range(0,100):
    # time.sleep(0.3)
    bar.progress(i)

# ============ Taking User Input ==========

st.subheader('Students Registration')
email = st.text_input('Enter E-mail')
marks = st.number_input('Enter Marks')

reg_date = st.date_input('Select Registration Date')

# DropDown
gender = st.selectbox('Select Gender', ['Male', 'Female'])

feedback_ = st.text_area('Feedback')

# file uploader
file = st.file_uploader('Select CSV File')

if file is not None:
    df = pd.read_csv(file)
    st.dataframe(df.describe())

# button
btn = st.button('Register')

if btn:
    if email is not "" and marks is not "":
        st.balloons()
        st.success('Register Successfully!')
        st.write(gender)
    else:
        st.error('Please Enter details!')
