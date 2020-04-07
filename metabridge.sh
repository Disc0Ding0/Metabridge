#!/bin/bash
echo 'Initialisating, please wait.'

# Ensure the default file structure is created
if [ ! -d 'filestore' ]
then
    mkdir filestore
elif [ ! -d 'previous_analysis' ]
then
    mkdir previous_analysis
fi

echo "Initialised."

echo "Choose an Option:"
echo "1. Start a new Job"
echo "2. Analysis a pre-collected filestore"
echo "3. Cleanse the filestore"
read -p "Option : " option

until [ -n "$option" ]
do
	read -p "You must select an option : " option
done

if [ $option == "1" ]
then

if [ -f 'results.txt' ]
then
    echo "Seems your environment is not clean, please restart and cleanse your files option three"
    exit 1
fi
# Collect information we need
read -p "Please enter the target domain : " target
until [ -n "$target" ]
do
	read -p "You cannot leave this empty, please enter a target: " target
done

read -p "Do you wish to change the amount of files to scrape (By Default this is 50)? Y/N: " scrapeLimitChange
until [ -n "$scrapeLimitChange" ]
do
	read -p "You cannot leave this empty, please answer Y/N: " scrapeLimitChange
done

if [ $scrapeLimitChange == "Y" ]
then 
	read -p "Please enter the new amount of files to scrape: " scrapeLimit
	until [[ -n "$scrapeLimit" && $scrapeLimit -gt "0" ]]
	do
		read -p "You cannot leave this empty, please enter a limit: " scrapeLimit
	done
else
	scrapeLimit=50
fi

read -p "Do you wish to limit the amount of the amount of files that are downloaded for analysis? Y/N: " limitDownloadChange
until [ -n "$limitDownloadChange" ]
do
	read -p "You cannot leave this empty, please answer Y/N: " limitDownloadChange
done

if [ $limitDownloadChange == "Y" ]
then
	read -p "Please enter your new limit, it must be lower than the previously stipulated limit (This was $scrapeLimit): " downloadLimit
	until [ -n "$downloadLimit" ]
	do
		read -p "You cannot leave this empty, please answer Y/N: "
	done

	until [ $downloadLimit -lt $scrapeLimit ]
	do
		read -p "You cannot download this amount of files, this is greater than the amount of files you told me to scrape. Please re-enter the download limit: " downloadLimit
		until [[ -n "$downloadLimit" && $downloadLimit -gt "0" ]]
		do
			read -p "You cannot leave this empty, please enter a new download limit: " downloadLimit
		done
	done
else
	downloadLimit=$scrapeLimit
fi

read -p "Please enter the type of files you would like to scraped, in a list seperated by columns (Example: txt,pdf,png,jpg), this can also be set to ALL, to download any 3 letter file type (May take a while) : " filetypes

until [ -n "$filetypes" ]
do
	read -p "You cannot leave this blank, please enter the filetypes to download: " filetypes
done

# Display vars to user for confirmation
printf "\nTarget Domain: $target \n"
echo "Amount of Files to Scrape: $scrapeLimit"
echo "Amount of Files to Download: $downloadLimit"
echo "Filetypes to Target: $filetypes"
printf "\n+++++=============================+++++\n"
read -p "Is the information displayed above correct? Y/N: " initiate

until [ -n "$initiate" ]
do
	read -p "You cannot leave this blank, please answer Y/N: " initiate
done

if [ $initiate == "Y" ]
then
	printf "\n Starting Scrape and Download...\n"
	
	# Initiate goofil
       metagoofil -d $target -t $filetypes -l $scrapeLimit -n $downloadLimit -o filestore

	read -p "Would you like to start the analysis process? Y/N: " initiateAnalysis
	until [ -n "$initiateAnalysis" ]
	do
		read -p "You cannot leave this blank, please answer Y/N: "initiateAnalysis
	done
	
	# Initiate ExifTool
	if [ $initiateAnalysis == "Y" ]
	then
		cd filestore
		exiftool . > ../results.txt
		cd ..

		printf "\n All Finished! Outputted to results.txt \n"

		read -p "Should I store the filestore as a backup and cleanse (If you are finished with the data, you should do this) Y/N : " cleanse

		until [[ -n "$cleanse" && ($cleanse == "Y" || $cleanse == "N") ]]
		do
			read -p "Sorry, you need to select an option, Y/N : " cleanse
		done

		if [ $cleanse == "Y" ]
		then	
			read -p "Please enter a name to store this under within your backups : " backup_name
			until [ -n "$backup_name" ]
			do
				read -p "You must provide a backup name : " backup_name
			done

			until [ ! -d "previous_analysis/$backup_name" ]
			do
				read -p "Sorry, $backup_name already exists, please choose another name : " backup_name
			done
            mkdir previous_analysis/$backup_name
			cp -r filestore previous_analysis/$backup_name/filestore
			cp results.txt previous_analysis/$backup_name/results.txt
			rm -r filestore
			rm results.txt

			echo "Success! A backup of the PDFs and results have been stored here: previous_analysis/$backup_name!"
		elif [ $cleanse == "N" ]
		then
			echo "Everything remains as is, remember, if you want to start again to cleanse your environment!"
		fi
	else
		echo "Aborting Meta Analysis....."
		read -p "Would you like to cleanse the filestore or preserve it for later analysis? cleanse or preserve" filestoreOption
		until [[ -n "$filestoreOption" && ($filestoreOption == "cleanse" || $filestoreOption == "Cleanse" || $filestoreOption == "preserve" || $filestoreOption == "Preserve") ]]
		do
			read -p "The value supplied is blank or invalid, please choose an option, cleanse or preserve" filestoreOption
		done

		if [[ $filestoreOption == "Cleanse" || $filestoreOption == "cleanse" ]]
		then
			rm -r filestore
			mkdir filestore
			echo "filestore cleansed and ready to go again..."
		elif [[ $filestoreOption == "preserve" || $filestoreOption == "Preserve" ]]
		then
			echo "filestore preserved and ready for later analysis..."
		else
			echo "Sorry, something happened, please try again."
		fi
	fi
else 
	echo "Error...... Aborting!"
fi
elif [ $option == "2" ]
then
	echo "Analyzing..."
	cd filestore
    exiftool . > ../results.txt
    cd ..

    printf "\n All Finished! Outputted to results.txt \n"

    read -p "Should I store the filestore as a backup and cleanse (If you are finished with the data, you should do this) Y/N : " cleanse

    until [[ -n "$cleanse" && ($cleanse == "Y" || $cleanse == "N") ]]
    do
        read -p "Sorry, you need to select an option, Y/N : " cleanse
    done

    if [ $cleanse == "Y" ]
    then	
        read -p "Please enter a name to store this under within your backups : " backup_name
        until [ -n "$backup_name" ]
        do
            read -p "You must provide a backup name : " backup_name
        done

        until [ ! -d "previous_analysis/$backup_name" ]
        do
            read -p "Sorry, $backup_name already exists, please choose another name : " backup_name
        done
        mkdir previous_analysis/$backup_name
        cp -r filestore previous_analysis/$backup_name/filestore
        cp results.txt previous_analysis/$backup_name/results.txt
        rm -r filestore
        rm results.txt

        echo "Success! A backup of the PDFs and results have been stored here: previous_analysis/$backup_name!"
		elif [ $cleanse == "N" ]
		then
			echo "Everything remains as is, remember, if you want to start again to cleanse your environment!"
		fi
elif [ $option == "3" ]
then
	echo "Which cleanse option would you like:"
	echo "1. Remove previous files"
	echo "2. Store previous files"
    read -p "Option, 1 or 2 : " cleanseOption
	
	until [[ -n "$cleanseOption" && ( $cleanseOption == "1" || $cleanseOption == "2") ]]
	do
        read -p "You must supply a valid option, either 1 or 2"
    done
    
    if [ $cleanseOption == "1" ]
    then
        if [ -f "results.txt" ]
        then
            rm results.txt
        fi
        rm -r filestore
        mkdir filestore
        echo "All removed and ready to go again!"
    elif [ $cleanseOption == "2" ]
    then
        read -p "Please enter a name to store this under within your backups : " backup_name
                until [ -n "$backup_name" ]
                do
                    read -p "You must provide a backup name : " backup_name
                done

                until [ ! -d "previous_analysis/$backup_name" ]
                do
                    read -p "Sorry, $backup_name already exists, please choose another name : " backup_name
                done
                mkdir previous_analysis/$backup_name
                cp -r filestore previous_analysis/$backup_name/filestore
                cp results.txt previous_analysis/$backup_name/results.txt
                rm -r filestore
                rm results.txt

                echo "Success! A backup of the PDFs and results have been stored here: previous_analysis/$backup_name!"
    fi
else
	echo "Sorry, that argument is unrecognised..."
fi
