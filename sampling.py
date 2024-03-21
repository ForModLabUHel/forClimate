import numpy as np

def current_climate_selector(nyears:int,simyears:int):
    """
    Sample  years from the available weather data and generate
    a vector of indexes to select daily data
    @param nyears Number of years available weather (20 years)
    @param simyears Simulation years (5 years)
    @retval ravel_days Vector of day numbers length of simyears to select daily weather
    @note Random sampling tries to emulate natural variation in annual weather
    """
    days=365
    #Sample nyears years out of simyears
    years = np.random.randint(1,nyears,simyears)
    #Now: generate 365 repetitions for each year
    repeat_years = np.repeat(years-1,days)
    #Split to simyears vectors (vector of vectors)
    split_years = np.split(repeat_years,simyears)
    #Add day number to each year
    add_days = split_years[:]+np.array(range(1,days+1))
    #Join all vectors into one single vector indexing daily weather
    ravel_days = np.ravel(add_days)
    return ravel_days

def climate_scenario_selector(csdb_start:int,sim_start:int,simyears):
    """
    Select climate scanario daily weather data for simulation years
    @param csdb_start Start calendar year for the data in climate scenario data
    @param sim_start calendar year for the simulation start
    @param simyears Simulation years
    @retval ravel_days Vector of day numbers to index daily weather data for simulation years
    @note Selection is determinstic for consecutive `simyears` years.
    """
    days=365
    start_index = sim_start-csdb_start
    years = start_index+np.array(range(1,simyears+1))
    repeat_years = np.repeat((years-1)*days,days)
    split_years = np.split(repeat_years,simyears)
    add_days = split_years[:]+np.array(range(1,days+1))
    ravel_days = np.ravel(add_days)
    return ravel_days
