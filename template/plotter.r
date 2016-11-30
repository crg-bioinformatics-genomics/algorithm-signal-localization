args <- commandArgs(trailingOnly = TRUE)
sltable<-read.table(args[1])
start<-sltable[,1]
end<-sltable[,2]
val<-sltable[,3]
n=length(sltable[,1])
pal<- colorRampPalette(c('blue','white', 'red'))

colsabs<- paste0(pal(n)[as.numeric(cut(c(val,1,0), breaks = n))], 99)
colsabs[which(!startsWith(colsabs,"#"))] ="#000000"

colsrel<- paste0(pal(n)[as.numeric(cut(val, breaks = n))], 99)
colsrel[which(!startsWith(colsrel,"#"))] ="#000000"

pdf("binding_sites.pdf",width=10,height=3.5)

plot(x= start, y= rep(0, n), type= 'n', bty= 'n', yaxt= 'n',
     ylab= '', xlab= 'Nucleotide Position', xlim= range(c(start, end)), ylim= c(0, 1))

rect(xleft= start, xright= end, ybottom= 0, ytop= 0.1, border= NA, col= colsabs)
rect(xleft= start, xright= end, ybottom= 0.1, ytop= 0.2, border= NA, col= colsrel)
#text(x= start, y= 0.12, labels= sprintf("%.2f", val), adj= c(0,0))

dev.off()
