# COVID Data Analysis Project

This project utilizes COVID-19 data obtained from [Our World in Data](https://ourworldindata.org/covid-deaths)  on November 27, 2023. Please note that the dataset might have undergone changes at the source due to daily updates.

The dataset used in this project spans from January 8, 2020, to November 22, 2023. The dataset has been reformatted and divided into two parts: **Data_death** and **Data_vaccination**.

## Project Overview

The project encompasses the following steps:

- Selection of data for Southeast Asian countries
- Definition of a Common Table Expression (CTE) named SelectedColumns that extracts specific columns from the coviddeath table within the covid19_data_db database
- Retrieval of selected columns from the CTE and ordering the result by location and date
- Calculation of death percentages based on total deaths and total cases
- Identification of countries with the highest infection rates compared to their population
- Identification of countries with the highest death counts compared to their population
- Calculation of total daily cases and deaths
- Modification of the column type from varchar to int in the covidvaccination table
- Joining of the coviddeath and covidvaccination tables
- Retrieval of data from the joined tables, ordered by location and date
- Presentation of the percentage of the population that has received the Covid vaccine

## Dashboard Visualization

A dashboard visualization is available [here](www.looker.com) for a more interactive view of the data analysis results.

This project aims to provide insights into the COVID-19 situation in Southeast Asian countries, highlighting key metrics such as death percentages, infection rates, vaccination coverage, and daily case counts. The analysis involves various SQL queries, data manipulation, and calculations to derive meaningful insights from the dataset.
