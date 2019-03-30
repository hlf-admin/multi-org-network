 
 YELLOW='\033[1;33m'
 RED='\033[1;31m'
 GREEN='\033[1;32m'
 RESET='\033[0m'

# indent text on echo
function indent() {
  c='s/^/       /'
  case $(uname) in
    Darwin) sed -l "$c";;
    *)      sed -u "$c";;
  esac
}

function showStep ()
    {
        echo -e "${YELLOW} $* ${RESET}" | indent
    }

function showSuccess ()
    {
        echo -e "${GREEN} $* ${RESET}" | indent
    }

function showFailure ()
    {
        echo -e "${RED} $* ${RESET}" | indent
    }

iteratePeers () {
    CHANNEL_NAME=$1
	for org in 1 2; do
	    for peer in 0 1; do
		checkInContainer $peer $org $CHANNEL_NAME
	    done
	done
}

arr_result[0]=""
arr_flag[0]=0

checkInContainer () {
    PEER=$1
	ORG=$2
    CHANNEL_NAME=$3
    var="$(docker exec -e \"CORE_CHAINCODE_LOGGING_LEVEL=ERROR\" peer${PEER}.org${ORG}.example.com peer channel list)"

    flag=`echo $var|awk -v CHANNEL_NAME="$3" '{print match($0,CHANNEL_NAME)}'`;

    let a=`expr $ORG - 1`
    let b=`expr $a \* 2`
    let index=`expr $b + $PEER`

    if [ $flag -gt 0 ];then
        echo "=>>>>>>>Success"
        echo
        echo $index 
        echo
		arr_result[index]="===================== peer${peer}.org${org} joined the channel  ===================== "
		arr_flag[index]=1
    else
        echo
        echo "=>>>>>>>Failed"
		arr_result[index]="===================== peer${peer}.org${org} FAILED to join the channel  ===================== "
		arr_flag[index]=0
    fi
}

iteratePeers $1
clear
showStep "Status of Peers who joined the Channel => $1"
echo
for (( i=0; i<${#arr_result[@]}; i++ )); do 
    if [ ${arr_flag[i]} -gt 0 ];then
        showSuccess ${arr_result[i]}; 
    else
        showFailure ${arr_result[i]}; 
    fi
done

echo

