$sum=0

#get proccessor time 
$values = (get-counter '\process($processname)\% processor time' -SampleInterval 1 -MaxSamples $sampletime).countersamples.cookedvalue

#get processor time sum
foreach($value in $values)
{
$sum=$sum+$value
}

#get cpu numbers
$cpuno = (Get-WmiObject -class win32_processor).numberoflogicalprocessors

#get average processor time
$ave = $sum/$cpuno
echo "the average is $ave"
