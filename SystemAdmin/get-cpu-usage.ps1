#get the cpu usage of a specific process in a period of time
(Get-Counter '\process($porcessname)\% processor time' -SampleInterval $interval -MaxSamples $times).countersamples.cookedvalue