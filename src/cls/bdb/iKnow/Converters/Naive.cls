/// <p>Naive <class>%iKnow.Source.Converter</class> implementation that doubles up
/// line breaks.</p>
/// This class is not designed for superb performance.
Class bdb.iKnow.Converters.Naive Extends %iKnow.Source.Converter
{

Property REBreak As %Regex.Matcher;

Method %OnNew(params As %String) As %Status [ Private, ServerOnly = 1 ]
{
    set ..REBreak = ##class(%Regex.Matcher).%New("(.)\r?\n(.)")
	kill ^||IK.Conv, ^||IK.ConvDone
    quit ##super($g(params))
}

/// Buffer data in a PPG
Method BufferString(data As %String) As %Status
{
	set ^||IK.Conv($i(^||IK.Conv)) = data
	quit $$$OK
}

Method Convert() As %Status
{
    set sc = $$$OK
    try {
        set nlbr = $c(13,10)

        set i = ""
        for {
            set i = $order(^||IK.Conv(i), 1, data)
            quit:i=""

            set ..REBreak.Text = data
            set ^||IK.ConvDone($i(^||IK.ConvDone)) = ..REBreak.ReplaceAll("$1"_nlbr_nlbr_"$2")
        }
        set ^||IK.ConvDone=0
    
    } catch (ex) {
        set sc = ex.AsStatus()
    }
    quit sc
}

/// Loop through the PPG again and return processed strings.
Method NextConvertedPart() As %String
{
	set currentIndex = $g(^||IK.ConvDone)
	set nextIndex = $order(^||IK.ConvDone(currentIndex),1,string)
	
	if (nextIndex="") {
		kill ^||IK.ConvDone, ^||IK.Conv
		quit ""
	}
	set ^||IK.ConvDone = nextIndex
	
	quit string
}

}
