#!/bin/bash
CMD="/sbin/ausearch --input-logs -m ADD_USER,DEL_USER,USER_CHAUTHTOK,ADD_GROUP,DEL_GROUP,CHGRP_ID,ROLE_ASSIGN,ROLE_REMOVE -i"
OUTPUT=$(${CMD} | sed "s/'//g");

if [[ $? -eq 0 ]]
then
    echo "["; # Json array start
    IFS=$'\n';
    for line in $OUTPUT; do
        if [[ ${line:0:4} == 'type' ]]
        then
            echo "{" #Json object start
            declare -A RECORD_MAP=();
            KEY_VALUE_PAIR_OUTPUT=$(echo $line | sed -r 's/[[:alnum:]]+=/\n&/g' | awk -F= '{print $1 "=" $2}' | sed -n '/^[^=]/p');

            for kv in $KEY_VALUE_PAIR_OUTPUT; do
                # echo "$kv";
                K=${kv%=*};
                V=${kv#*=};
                

                if [ -z ${RECORD_MAP[$K]+"isset"} ];then
                    echo "\"$K\":\"$V\","; # Json key value pair of object
                fi

                RECORD_MAP[$K]=$V;
            done
            echo "\"raw\":\"$line\"";
            echo "}," #Json object end
        fi
    done
    echo "]"; # JSON array end
    
else
    echo "else";
fi

# JSON generated by script leaves trailing commas
# if that is a problem with your JSON parse use a regex like this:
# regex = /\,(?!\s*?[\{\[\"\'\w])/g;
