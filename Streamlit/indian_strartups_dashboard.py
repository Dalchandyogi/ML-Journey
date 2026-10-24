import streamlit as st
import  matplotlib.pyplot as plt
import  pandas as pd
import seaborn as sns

plt.style.use('dark_background')

st.set_page_config(layout='wide', page_title='Indian Startups')

df = pd.read_csv('startup_funding.csv')

def make_metric(label, number):
    st.metric(label, str(number) + ' Cr')

def make_metric_text(label, text):
    st.metric(label, text)


def load_investor_details(name):
    st.title(name)

    # recent investments
    recent_df = df[df['investors'].str.contains(name)].head()[['date', 'startup', 'vertical', 'city', 'round', 'amount']]

    st.subheader('Most Recent Investments')
    st.dataframe(recent_df, hide_index=True)

    # data points
    big_invest = df[df['investors'].str.contains(name)].groupby('startup')['amount'].sum().sort_values(ascending=False).head()
    sector_invest = df[df['investors'].str.contains(name)].groupby('vertical')['amount'].sum()
    invest_stage = df[df['investors'].str.contains(name)].groupby('round')['amount'].sum()
    city_invest = df[df['investors'].str.contains(name)].groupby('city')['amount'].sum()
    yoy_invest = df[df['investors'].str.contains(name)].groupby('year')['amount'].sum()


    # cols
    col1, col2 = st.columns(2)
    col3, col4 = st.columns(2)

    with col1:
        st.subheader('Biggest Investments')

        # Set explicit figure size (e.g., width=6, height=4)
        fig, ax = plt.subplots(figsize=(6, 4))
        ax.bar(big_invest.index, big_invest.values)

        # Add X and Y labels
        ax.set_xlabel('Startup')
        ax.set_ylabel('Amount(Cr)')

        st.pyplot(fig)

    with col2:
        st.subheader('Investments Sector Wise')

        fig, ax = plt.subplots(figsize=(6, 4))
        ax.pie(sector_invest, autopct='%0.2f%%')
        ax.legend(sector_invest.index, loc="upper left", bbox_to_anchor=(1, 1))

        st.pyplot(fig)

    with col3:
        st.subheader('Investments Stage')

        fig, ax = plt.subplots(figsize=(6, 4))
        ax.pie(invest_stage, autopct='%0.2f%%')
        ax.legend(invest_stage.index, loc="upper left", bbox_to_anchor=(1, 1))

        st.pyplot(fig)

    with col4:
        st.subheader('Investments City')

        fig, ax = plt.subplots(figsize=(6, 4))
        ax.pie(city_invest, autopct='%0.2f%%')
        ax.legend(city_invest.index, loc="upper left", bbox_to_anchor=(1, 1))

        st.pyplot(fig)

    st.subheader('Year On Year Investments')

    fig, ax = plt.subplots(figsize=(4, 2))
    ax.plot(yoy_invest.index, yoy_invest.values, marker='o', linewidth=1, markersize=1.2)

    # Add X and Y labels
    ax.set_xlabel('Year')
    ax.set_ylabel('Amount(Cr)')



    st.pyplot(fig)


def show_overall_analysis():
    col_all_1, col_all_2, col_all_3, col_all_4 = st.columns(4)

    total = round(df['amount'].sum())
    max_funding = df.groupby('startup')['amount'].max().sort_values(ascending=False).head(1).values[0]
    avg_funding = round(df.groupby('startup')['amount'].sum().mean())
    total_funded_startup = df['startup'].nunique()

    with col_all_1:
        make_metric('Total Investment', total)
    with col_all_2:
        st.metric('Max Funding', str(max_funding) + ' Cr', delta='Rapido Bike Taxi', delta_color='green', delta_arrow='off')
    with col_all_3:
        make_metric('Avg. Funding', avg_funding)
    with col_all_4:
        make_metric('Funded StartUp', total_funded_startup)

    st.markdown("---")

    st.subheader("MoM Graph")

    # 1. Option to choose between Total Investment Amount or Number of Startups
    graph_type = st.radio('Select MoM Metric', ['Total Amount (Cr)', 'Number of Startups'], horizontal=True)

    # 2. Year selector
    # Get unique years from the dataframe
    years = sorted(df['year'].dropna().unique())
    selected_year = st.selectbox('Select Year', years)

    fig, ax = plt.subplots(figsize=(8, 4))

    if graph_type == 'Total Amount (Cr)':
        # Group by year and month for total investment amount[cite: 10]
        invest_df = df.groupby(['year', 'month'])['amount'].sum().reset_index()
        filtered_df = invest_df[invest_df['year'] == selected_year]

        # Plot line chart for amount
        ax.plot(filtered_df['month'], filtered_df['amount'], marker='o',  linestyle='-', linewidth=1,markersize=1.8)
        ax.set_ylabel('Total Amount (Cr)')
        ax.set_title(f'MoM Total Investment Amount Trend for {selected_year}')

    else:
        # Group by year and month for startup count
        temp_df = df.groupby(['year', 'month'])['startup'].count().reset_index()
        filtered_df = temp_df[temp_df['year'] == selected_year]

        # Plot line chart for startup count
        ax.plot(filtered_df['month'], filtered_df['startup'], marker='o', linestyle='-', linewidth=1, markersize=1.8)
        ax.set_ylabel('Number of Startups')
        ax.set_title(f'MoM Startup Funding Trend for {selected_year}')

    # Common axis settings
    ax.set_xlabel('Month')
    ax.set_xticks(range(1, 13))

    # Render the plot in Streamlit
    st.pyplot(fig)


    col5, col6 = st.columns(2)

    types_funding = df['round'].value_counts().head(5)

    with col5:
        st.subheader('Type of Funding')
        fig, ax = plt.subplots(figsize=(6, 4))

        def clear_labels(pct):
            return f'{pct:.1f}%' if pct > 2 else ''  # Only show text if percentage is > 2%

        wedges, texts, autotexts = ax.pie(
            types_funding,
            autopct=clear_labels,  # Uses our custom function to filter tiny text
            pctdistance=0.75,  # Pushes the percentages outward from the center
            textprops=dict(color="white", weight="bold")  # Makes text bold and white for readability
        )

        # Refine the legend so all types are clearly readable on the side
        ax.legend(
            wedges,
            types_funding.index,
            title="Funding Types",
            loc="upper left",
            bbox_to_anchor=(1, 1)
        )

        st.pyplot(fig)

    with col6:
        st.subheader('City wise Funding')
        city_wise_funding = df['city'].value_counts().head(8)

        fig, ax = plt.subplots(figsize=(6, 4))

        def clear_labels(pct):
            return f'{pct:.1f}%' if pct > 2 else ''  # Only show text if percentage is > 2%

        wedges, texts, autotexts = ax.pie(
            city_wise_funding,
            autopct=clear_labels,  # Uses our custom function to filter tiny text
            pctdistance=0.75,  # Pushes the percentages outward from the center
            textprops=dict(color="white", weight="bold")  # Makes text bold and white for readability
        )

        # Refine the legend so all types are clearly readable on the side
        ax.legend(
            wedges,
            city_wise_funding.index,
            title="City",
            loc="upper left",
            bbox_to_anchor=(1, 1)
        )

        st.pyplot(fig)


    st.subheader('Top Startups')

    # Create your layout columns for the filters
    col7, col8 = st.columns(2)

    with col7:
        select = st.selectbox('Select Option', ['Overall', 'Yearly'], key='top_startups_option')

    with col8:
        ranking_metric = st.selectbox(
            "Rank Top Startups By:",
            ['Total Funding Amount', 'Number of Funding Rounds'],
            key='top_startups_metric'
        )

    # Filter dataframe based on 'Overall' or 'Yearly' selection
    if select == 'Yearly':
        # Let user pick a year if 'Yearly' is chosen
        years = sorted(df['year'].dropna().unique())
        selected_year = st.selectbox('Select Year for Top Startups', years, key='top_startups_year')

        # Filter the dataframe for that specific year
        analysis_df = df[df['year'] == selected_year]
        title_suffix = f'in {selected_year}'
    else:
        # Use the full dataframe for 'Overall'
        analysis_df = df
        title_suffix = 'Overall (All Years)'

    # Calculate top startups based on the chosen ranking metric
    if ranking_metric == 'Total Funding Amount':
        top_startups = analysis_df.groupby('startup')['amount'].sum().sort_values(ascending=False).head(10)
        y_label = 'Total Amount (Cr)'
    else:
        top_startups = analysis_df.groupby('startup')['amount'].count().sort_values(ascending=False).head(10)
        y_label = 'Number of Funding Rounds'

    # Plotting the top startups chart
    fig, ax = plt.subplots(figsize=(8, 4))

    # Optional: ensure transparency matches your dark theme
    fig.patch.set_facecolor('none')
    ax.set_facecolor('none')

    ax.bar(top_startups.index, top_startups.values, color='#4c78a8')
    ax.set_ylabel(y_label)
    ax.set_xlabel('Startup')
    ax.set_title(f'Top 10 Startups by {ranking_metric} — {title_suffix}')
    plt.xticks(rotation=45, ha='right')

    st.pyplot(fig)

    st.subheader('Top Investors')

    # Create columns for filtering options
    col_inv1, col_inv2 = st.columns(2)

    with col_inv1:
        investor_select = st.selectbox('Select Option', ['Overall', 'Yearly'], key='top_investors_option')

    with col_inv2:
        investor_metric = st.selectbox(
            "Rank Top Investors By:",
            ['Total Funding Amount', 'Number of Investments'],
            key='top_investors_metric'
        )

    # Filter dataframe based on 'Overall' or 'Yearly' selection
    if investor_select == 'Yearly':
        years = sorted(df['year'].dropna().unique())
        selected_investor_year = st.selectbox('Select Year for Top Investors', years, key='top_investors_year')
        investor_analysis_df = df[df['year'] == selected_investor_year]
        investor_title_suffix = f'in {selected_investor_year}'
    else:
        investor_analysis_df = df
        investor_title_suffix = 'Overall (All Years)'

    # Note: In startup datasets, the 'investors' column might contain multiple investors separated by commas.
    # Depending on how your data is structured, you can group directly or explode if needed.
    # Assuming standard grouping for capital sum or count:
    if investor_metric == 'Total Funding Amount':
        top_investors = investor_analysis_df.groupby('investors')['amount'].sum().sort_values(ascending=False).head(10)
        inv_y_label = 'Total Amount (Cr)'
    else:
        top_investors = investor_analysis_df.groupby('investors')['amount'].count().sort_values(ascending=False).head(
            10)
        inv_y_label = 'Number of Investments'

    # Plotting the top investors chart
    fig, ax = plt.subplots(figsize=(8, 4))

    # Transparency and theme styling
    fig.patch.set_facecolor('none')
    ax.set_facecolor('none')

    ax.bar(top_investors.index, top_investors.values,
           color='#e15759')  # Using a distinct color like coral/red for investors
    ax.set_ylabel(inv_y_label)
    ax.set_xlabel('Investor')
    ax.set_title(f'Top 10 Investors by {investor_metric} — {investor_title_suffix}')
    plt.xticks(rotation=45, ha='right')

    st.pyplot(fig)

    st.subheader("Funding Heatmap (Year vs Month)")

    # 1. Create a pivot table: Rows = Year, Columns = Month, Values = Total Amount (or Count)
    heatmap_metric = st.radio("Heatmap Metric", ['Total Amount (Cr)', 'Number of Funding'], horizontal=True,
                              key='heatmap_metric_radio')

    if heatmap_metric == 'Total Amount (Cr)':
        pivot_df = df.pivot_table(index='year', columns='month', values='amount', aggfunc='sum').fillna(0)
        cbar_label = 'Amount (Cr)'
    else:
        pivot_df = df.pivot_table(index='year', columns='month', values='startup', aggfunc='count').fillna(0)
        cbar_label = 'Number of Startups'

    # 2. Plotting the Heatmap
    fig, ax = plt.subplots(figsize=(10, 5))

    # Transparency styling to match your dark theme
    fig.patch.set_facecolor('none')
    ax.set_facecolor('none')

    # Use seaborn heatmap for beautiful, clean coloring
    sns.heatmap(
        pivot_df,
        cmap='YlGnBu',  # Color palette (Yellow-Green-Blue)
        linewidths=0.5,  # Small gaps between grid cells
        linecolor='#222222',  # Dark grid lines for contrast
        ax=ax,
        cbar_kws={'label': cbar_label}
    )

    # Customizing labels and layout
    ax.set_title(f'Funding Heatmap by {heatmap_metric}', color='white', fontsize=14)
    ax.set_xlabel('Month', color='white')
    ax.set_ylabel('Year', color='white')

    # Adjust tick label colors for dark mode visibility
    ax.tick_params(colors='white', which='both')

    st.pyplot(fig)


def load_company_details(df, company_name):

    st.title(company_name)
    st.markdown("---")
    # Filter dataframe for the selected company (case-insensitive)
    comp_df = df[df['startup'].str.contains(company_name, case=False, na=False)]

    if comp_df.empty:
        return None

    name = comp_df['startup'].values[0]
    industry = comp_df['vertical'].values[0] if 'vertical' in comp_df.columns else 'N/A'
    subindustry = comp_df['subvertical'].values[0] if 'subvertical' in comp_df.columns else 'N/A'

    location = comp_df['city'].values[0] if 'city' in comp_df.columns else 'N/A'

    # Funding rounds breakdown (Stage, Investors, Amount, Date/Year)
    date_col = 'date' if 'date' in comp_df.columns else 'year'
    funding_rounds = comp_df[['round', 'investors', 'amount', date_col]].to_dict(orient='records')

    # Find similar companies (operating in the same industry/vertical)
    similar_companies = df[(df['vertical'] == industry) & (df['startup'] != name)]['startup'].unique()[:5].tolist()

    return {
        'name': name,
        'industry': industry,
        'subindustry': subindustry,
        'location': location,
        'funding_rounds': funding_rounds,
        'similar_companies': similar_companies
    }

st.sidebar.title("Indian StartUp Analysis")
option = st.sidebar.selectbox('Select one', ['Overall Analysis', 'StartUp', 'Investor'])

if option == 'Overall Analysis':
    st.title('Overall Analysis')
    st.markdown("---")
    show_overall_analysis()

elif option == 'StartUp':
    selected_startup = st.sidebar.selectbox('Select StartUp', sorted(df['startup'].unique().tolist()))
    btn1 = st.sidebar.button('Find StartUp')

    if btn1:

        if selected_startup:
            details = load_company_details(df, selected_startup)

            if details:
                # Display General Info in columns
                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    make_metric_text('Industry', f'{details['industry']}')

                with col2:
                    make_metric_text('Subindustry', f'{details['subindustry']}')

                with col3:
                    make_metric_text('Location', f'{details['location']}')
                with col4:
                    total_raised = sum([r['amount'] for r in details['funding_rounds'] if pd.notnull(r['amount'])])
                    make_metric('Total Funding', total_raised)

                st.markdown("---")

                # Funding Rounds Table/Details
                st.subheader("Funding Rounds History")
                rounds_df = pd.DataFrame(details['funding_rounds'])
                st.dataframe(rounds_df, use_container_width=True)

                # Similar Companies
                st.subheader("Similar Companies")
                if details['similar_companies']:
                    st.write(", ".join(details['similar_companies']))
                else:
                    st.info("No similar companies found in this vertical.")
            else:
                st.warning("No details found for this company.")



else:
    # st.title('Investor')
    investor = st.sidebar.selectbox('Select Investor', sorted(set(df['investors'].str.split(',').sum())))
    btn2 = st.sidebar.button('Find Investor')

    if btn2:
        load_investor_details(investor)