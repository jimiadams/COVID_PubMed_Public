# covid_pubmed
This project is pulling data from PubMed to construct collaboration networks from COVID-19 publications in Dec 2019 - Mar 18 2020. This work is in collaboration with [Ryan Light](https://github.com/lightsociologist). An outline of the workflow here:

**NOTE: This repo does not include our raw, nor compiled datasets, to comply with PubMed data use agreements. We've only posted the final data objects used in the figures, as noted in *italics* below.**

1. **pubmed_covid.R**: scraping the files and doing some initial processing. This produces the following data files:

    a. the .txt files are the raw pulls from PubMed
    
    b. pubmed_articeles.Rda & 
    
    c. pubmed_authors.Rda which each include some basic processing of the txt files
    
2. **coauthors.R**: converting some of the results from above into collaboration networks of various forms. This pulls from 1c, and produces:

    a. *collab_net.rds* data file of full collaboration network
    
    b. comm_membs.rda data file with network community memberships
    
    c. figs\net_fig.png illustrations of the collaboration network

3. **author_keywords.R**: processes the keywords information. This depends on 1b, 1c, and 2a. It produces the following:

    a. keywords.Rda - primarily an author by keyword file, with a few other elements
    
    b. top_keywords.Rda - a table of keywords by network community

4. **make_art_map.R**: generates the article count map. It depends on 1b, 1c and creates:

    a. *country_hand.csv* hand cleaned country file based on PubMed address field for map
    
    b. figs\artmap_fin.pdf map of article contributions by country

5. **grps_country.R**: tabulates the community-country overlap. It depends on 1b, 1c, 2a, 4a, and generates

    a. *top_countries_grp.Rda* - processed countr-by-article table for the map

Perhaps obvious, but just in case:

- There are html and pdf and docx versions of the submitted version of the manuscript in the docs folder. If there are differences, the html version is likely the most up-to-date.
