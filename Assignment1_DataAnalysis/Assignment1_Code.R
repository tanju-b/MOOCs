#Obtain working data from assignment prompt
fileUrl <- "https://spark-public.s3.amazonaws.com/dataanalysis/loansData.rda"
download.file(fileUrl,destfile="./data/loans.rda")
dateDownloaded <- date()
dateDownloaded
#
# load file loan.rda and perform initial explore
load("./data/loans.rda")
dim(loansData)
str(loansData)

#Convert Interest Rate to a num using function found on course forums that removes the %s from the strings using gsub
## > loansData$Interest.Rate <- as.numeric(gsub("%$", "", loansData$Interest.Rate))
## The pattern "%$" says to find a % symbol next to the end of the line, represented by the "$" here -- sorry $ is being used two different ways here .   gsub replaces the matches with "%$" with "", which removes the % symbols.
loansData$Interest.Rate <- as.numeric(gsub("%$", "", loansData$Interest.Rate))
# check to confirm 
str(loansData)
#Repeat for other factors and symbols 
loansData$Debt.To.Income.Ratio <- as.numeric(gsub("%$", "", loansData$Debt.To.Income.Ratio))
loansData$LoanLength <- as.integer(gsub(" months", "", loansData$LoanLength))

#Remove periods from variable names
names(loansData) <- gsub("\\.","",names(loansData))
#Lower Case "CREDIT" to "Credit"
names(loansData) <- gsub("REDIT","redit",names(loansData))
#Shorten Inquiriesinthelast6Months to Inquiries6mo
names(loansData) <- gsub("InquiriesintheLast6Months","Inquiries6mo",names(loansData))
#view summary of loansData
summary(loansData)


#Explore Variables
unique(loansData$LoanLength) #shows only two lengths 36 and 60
sum(is.na(loansData$InterestRate)) # gives 0
length(loansData$InterestRate)
length(loansData$FICORange)
length(unique(loansData$AmountRequested)) # gives 380....too many
#Cut amount requested into 7 levels with ranges of 5000 and store in AmtReq
AmtReq <- cut(loansData$AmountRequested,seq(0,35000,by=5000))
length(unique(loansData$FICORange)) # gives 38
###  this doesn't work, must be numeric vs factor::::: FICO <- cut(loansData$FICORange,seq(600,900,by=50))
length(unique(loansData$OpenCreditLines)) #gives 30
length(unique(loansData$HomeOwnership)) #gives 5
length(unique(loansData$Inquiries6mo)) #gives 5
summary(loansData$InterestRate)
#Box Plots
boxplot(loansData$AmountRequested ~ as.factor(loansData$LoanLength))
boxplot(loansData$InterestRate ~ as.factor(loansData$LoanLength),col="blue",xlab="Loan Length (mo.)",ylab="Interest Rate (%)",varwidth=TRUE,main="Interest Rate Range vs Loan Length")
boxplot(loansData$InterestRate ~ as.factor(loansData$FICORange),col="blue",xlab="FICO Range",ylab="Interest Rate (%)",varwidth=TRUE,)
boxplot(loansData$InterestRate ~ as.factor(loansData$OpenCreditLines),col="blue",xlab="Open Credit Lines",ylab="Interest Rate (%)",varwidth=TRUE)
boxplot(loansData$InterestRate ~ as.factor(loansData$HomeOwnership),col="blue",xlab="Home Ownership",ylab="Interest Rate (%)",varwidth=TRUE) #xlables are not really legible
boxplot(loansData$InterestRate ~ as.factor(loansData$Inquiries6mo),col="blue",xlab="Inquiries in Last 6 mo",ylab="Interest Rate (%)",varwidth=TRUE)
boxplot(loansData$InterestRate ~ as.factor(AmtReq),col="blue",xlab="Loan Amount Requested ($)",ylab="Interest Rate (%)",varwidth=TRUE,main="Interest Rate Range vs Loan Amount")
boxplot(loansData$InterestRate ~ as.factor(loansData$EmploymentLength),col="blue",xlab="Employment Length",ylab="Interest Rate (%)",varwidth=TRUE,main="Interest Rate Range vs Employment")
boxplot(loansData$InterestRate ~ as.factor(loansData$MonthlyIncome),col="blue",xlab="Employment Length",ylab="Interest Rate (%)",varwidth=TRUE,)
#Histograms
hist(loansData$AmountRequested,col="blue")
hist(loansData$InterestRate,col="blue")
hist(loansData$DebtToIncomeRatio,col="blue")
hist(loansData$LoanLength)

#Scatter Plots
length <- gsub("36","1",loansData$LoanLength)
length <- gsub("60","2",length)
plot(loansData$FICORange,loansData$InterestRate,pch=19,col=AmtReq,cex=0.5)
plot(loansData$MonthlyIncome,loansData$InterestRate,pch=19,col="blue",xlab="Monthly Income ($)",ylab="Interest Rate (%)",cex=0.5,main="Interest Rate Range vs Income")
plot(loansData$OpenCreditLines,loansData$InterestRate,pch=19,col="blue",cex=0.5)
plot(loansData$RevolvingCreditBalance,loansData$InterestRate,pch=19,col="blue",cex=0.5)
plot(jitter(loansData$Inquiries6mo,factor=1),loansData$InterestRate,pch=19,col="blue",cex=0.5)
plot(loansData$EmploymentLength,loansData$InterestRate,pch=19,col="blue",cex=0.5)
plot(jitter(loansData$LoanLength,),loansData$InterestRate,pch=19,col="blue",cex=0.5)

#kmeans of OpenCreditLines to Interest rates wont converge on the 3 outliers in upper right...takes 20 clusters
#First remove NA's due to kmeans error by creating a copy called openlines 
sum(is.na(loansData$OpenCreditLines))
openlines <- loansData$OpenCreditLines
sum(is.na(openlines))
#overwrite the NAs by subset to the NAs per line below
openlines[is.na(openlines)] <- 0
#kmeans code per lecture below
datafrm <- data.frame(loansData$OpenCreditLines,loansData$InterestRate)
kmeansObj <- kmeans(datafrm,19,iter.max=100000,nstart=300)
plot(openlines,loansData$InterestRate,col=kmeansObj$cluster,pch=19,cex=1)
points(kmeansObj$centers,col=1:10,pch=3,cex=3,lwd=3)

#Consider subsetting OpenLines greater than 31??
openlines[openlines>25]
datafrm[openlines > 25,]
summary(datafrm[loansData$OpenCreditLines > 25,])
summary(datafrm[loansData$OpenCreditLines < 25,])