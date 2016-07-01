# Whatsapp Analyzer (iOS) #

Native iOS application for analyzing whatsapp conversations freely on your own iOS device.
I wrote this app long time ago, (hence the objective-c code). 

### Goal ###
I had to prove someone that I said a certin word more times than he did. This was the empirical evidence to win our $10 bet :)

### What can you do with this ? ###

* Export .txt whatsapp converstaions into the app.
* Analyze whatsapp conversations.
     * How many messages ?
     * Who are the participants ?
     * Who sent the most messages ? 
     * What is the percentage of each person in the conversation?
     * etc...
* View cool graphs
    * 2 People conversation graphs (1 vs 1)
    * Group conversation graphs


### How to run with xCode ? ###

```sh
you$ mkdir Whatsapp-Analyzer && cd Whatsapp-Analyzer
you$ git clone https://github.com/SharonBrizinov/Whatsapp-Analyzer.git
you$ pod install
you$ ./WhatsappAnalyzer.xcworkspace
```

### Images ###

* Analyzing Conversations

![alt text](/images/1.png "Analyzing conversation 1")
![alt text](/images/2.png "Analyzing conversation 2")

---
* Graphs

![alt text](/images/3.png "New categories")
![alt text](/images/4.png "Graph - VS mode")

---
* Graphs 2

![alt text](/images/5.png "Graph - How many messages each participants sent ?")
![alt text](/images/6.png "Graph - How many times it has been said ?")