//+------------------------------------------------------------------+
//|                                                   LineNotify.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define DEFAULT_HTTPS_PORT     443
#define SERVICE_HTTP   3
#define FLAG_SECURE            0x00800000  // use PCT/SSL if applicable (HTTP)
#define FLAG_PRAGMA_NOCACHE    0x00000100  // asking wininet to add "pragma: no-cache"
#define FLAG_KEEP_CONNECTION   0x00400000  // use keep-alive semantics
#define FLAG_RELOAD            0x80000000  // retrieve the original item
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
#import "wininet.dll"
int InternetOpenW(string agent, int accessType, string proxyName, string proxyByPass, int flags);
int InternetConnectW(int internet, string serverName, int port, string userName, string password, int service, int flags, int context);
int HttpOpenRequestW(int connect, string verb, string objectName, string version2, string referer,int acceptType, uint flags, int context);
int HttpAddRequestHeadersW(int, string, int, int);
bool HttpSendRequestW(int hRequest,string &lpszHeaders,int dwHeadersLength,uchar &lpOptional[],int dwOptionalLength);
bool HttpQueryInfoW(int request, int infoLevel, string &buffer, int &size, int &index);
int InternetOpenUrlW(int internetSession, string url, string header, int headerLength, int flags, int context);
int InternetReadFile(int, uchar &arr[], int, int &byte);
int InternetCloseHandle(int winINet);
#import


#import "kernel32.dll"
int GetLastError(void);
#import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
string agent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string LineNotify(string message,string token)
  {
   string headers;
   string UserAgent = agent;
   string nill = "";
   string host = "notify-api.line.me";
   string Vers    = "HTTP/1.1";
   string POST    = "POST";
   string Object  = "/api/notify.php";

   string toStr = "";
   int session = 0;
   int connect = 0;
   int hRequest, hSend;

   int dwBytes;
   uchar post[];
   char buf[];
   uchar ch[100];
   if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
     {
      Print("DLL is not allowed");
      return(IntegerToString(false));
     }


   StringToCharArray("message=" + message,post,0, WHOLE_ARRAY, CP_UTF8);

   session = InternetOpenW(UserAgent, 0, nill, nill, 0);
   if(session <= 0)
     {
      if(session > 0)
         InternetCloseHandle(session);
      session = -1;
      if(connect > 0)
         InternetCloseHandle(connect);
      connect = -1;
      Print("Err CreateSession");
      return(NULL);
     }

   connect = InternetConnectW(session, host, DEFAULT_HTTPS_PORT, nill, nill, SERVICE_HTTP, 0, 0);
   if(connect <= 0)
     {
      if(session > 0)
         InternetCloseHandle(session);
      session = -1;
      if(connect > 0)
         InternetCloseHandle(connect);
      connect = -1;
      Print("Err create Connect");
      return(NULL);
     }



   hRequest = HttpOpenRequestW(connect, POST, Object, Vers, nill, NULL, FLAG_SECURE|FLAG_KEEP_CONNECTION|FLAG_RELOAD|FLAG_PRAGMA_NOCACHE, 0);
   if(hRequest <= 0)
     {
      if(session > 0)
         InternetCloseHandle(session);
      session = -1;
      if(connect > 0)
         InternetCloseHandle(connect);
      connect = -1;
      Print("Err OpenRequest");
      return(NULL);
     }

   headers = "Authorization: Bearer " + token + "\r\n";
   headers += "Content-Type: application/x-www-form-urlencoded\r\n";

//headers += "Content-Type: multipart/form-data\r\n";

   hSend = HttpSendRequestW(hRequest, headers, StringLen(headers), post, ArraySize(post));

   while(InternetReadFile(hRequest, ch, 100, dwBytes))
     {
      if(dwBytes <= 0)
         break;
      toStr = CharArrayToString(ch, 0, dwBytes);
     }

   if(hSend <= 0)
     {
      Print("Err SendRequest");
      if(connect > 0)
         InternetCloseHandle(hRequest);
      if(session > 0)
         InternetCloseHandle(session);
      session  = -1;
      if(connect > 0)
         InternetCloseHandle(connect);
      connect  = -1;
     }

   InternetCloseHandle(hSend);
   InternetCloseHandle(hRequest);
   if(session > 0)
      InternetCloseHandle(session);
   session = -1;
   if(connect > 0)
      InternetCloseHandle(connect);
   connect = -1;

   Print("Data Send : toStr");
   return(IntegerToString(hSend));
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string LineNotifyAt(string message,string token,string fileName)
  {

   string boundary;
   string body;
   string headers;
   string UserAgent = agent;
   string nill = "";
   string host = "notify-api.line.me";
   string Vers    = "HTTP/1.1";
   string POST    = "POST";
   string Object  = "/api/notify.php";
   string time;
   string toStr = "";
   int session = 0;
   int connect = 0;
   int hRequest, hSend;
   int ls;
   int dwBytes;
   uchar post[];
   char buf[];
   uchar ch[100];

   datetime dt1 = TimeLocal();
   time = TimeToString(dt1,TIME_DATE | TIME_SECONDS);
   StringReplace(time,".","");
   StringReplace(time,":","");
   StringReplace(time," ","");
   boundary ="-----------------------" + time;

   if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
     {
      Print("DLL is not allowed");
      return(IntegerToString(false));
     }

//StringToCharArray("message=" + message,post,0, WHOLE_ARRAY, CP_UTF8);

   session = InternetOpenW(UserAgent, 0, nill, nill, 0);
   if(session <= 0)
     {
      if(session > 0)
         InternetCloseHandle(session);
      session = -1;
      if(connect > 0)
         InternetCloseHandle(connect);
      connect = -1;
      Print("Err CreateSession");
      return(NULL);
     }


   connect = InternetConnectW(session, host, DEFAULT_HTTPS_PORT, nill, nill, SERVICE_HTTP, 0, 0);
   if(connect <= 0)
     {
      if(session > 0)
         InternetCloseHandle(session);
      session = -1;
      if(connect > 0)
         InternetCloseHandle(connect);
      connect = -1;
      Print("Err create Connect");
      return(NULL);
     }



   hRequest = HttpOpenRequestW(connect, POST, Object, Vers, nill, NULL, FLAG_SECURE|FLAG_KEEP_CONNECTION|FLAG_RELOAD|FLAG_PRAGMA_NOCACHE, 0);
   if(hRequest <= 0)
     {
      if(session > 0)
         InternetCloseHandle(session);
      session = -1;
      if(connect > 0)
         InternetCloseHandle(connect);
      connect = -1;
      Print("Err OpenRequest");
      return(NULL);
     }

   int fp = FileOpen(fileName,FILE_READ|FILE_BIN|FILE_COMMON);

   if(fp == INVALID_HANDLE)
     {
      FileClose(fp);
      Print("Do Not File READ:" +fileName);
      return NULL;
     }

   if(FileReadArray(fp,buf,0,WHOLE_ARRAY) ==0)
     {
      FileClose(fp);
      Print("Do Not File READ:" +fileName);
      return NULL;
     }
   FileClose(fp);
   headers = "Authorization: Bearer " + token + "\r\n";
//headers += "Content-Type: application/x-www-form-urlencoded\r\n";

   headers += "Content-Type: multipart/form-data; boundary=" + boundary + "\r\n";
   body = "--" + boundary + "\r\n";
   body+= "Content-Disposition: form-data; name=\"message\"\r\n";
   body+= "\r\n";
   body+= message;
   body+=  "\r\n";
   body+= "--" + boundary + "\r\n";
   body+= "Content-Disposition: form-data; name=\"imageFile\"; filename=\"" + fileName + "\"\r\n";
   body+= "Content-Type: image/png\r\n";
   body+= "\r\n";

   ls = StringToCharArray(body,post,0, WHOLE_ARRAY, CP_UTF8);
   ls+= ArrayCopy(post,buf,ls-1,0);
   ls+=StringToCharArray("\r\n" + "--" +  boundary + "--\r\n",post,ls-1);
   ArrayResize(post,ls-1);

   Print("\r\n" + headers + "\r\n" + CharArrayToString(post));
   hSend = HttpSendRequestW(hRequest, headers, StringLen(headers), post, ArraySize(post));

   while(InternetReadFile(hRequest, ch, 100, dwBytes))
     {
      if(dwBytes <= 0)
         break;
      toStr = CharArrayToString(ch, 0, dwBytes);
     }

   if(hSend <= 0)
     {
      Print("Err SendRequest");
      if(connect > 0)
         InternetCloseHandle(hRequest);
      if(session > 0)
         InternetCloseHandle(session);
      session  = -1;
      if(connect > 0)
         InternetCloseHandle(connect);
      connect  = -1;
     }

   InternetCloseHandle(hSend);
   InternetCloseHandle(hRequest);
   if(session > 0)
      InternetCloseHandle(session);
   session = -1;
   if(connect > 0)
      InternetCloseHandle(connect);
   connect = -1;

   Print("Data Send : "+toStr);
   return(IntegerToString(hSend));
  }
//+------------------------------------------------------------------+
