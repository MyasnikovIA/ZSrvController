/// <br>  Класс написан для организации обмена между серверами Cache'.
/// <br>  За счет прямого подключения между сервирами Cache` по указанному порту, достигается максимальная скорость.
/// <br>  Для соединения применяются пльзоватили системы.
/// <H3>  Обрабатываемые команды:</H3>
/// <pre><h4>
///    "ip"         -  Получить IP адрес клиента со стороны сервера
///    "run: w $h"  -  Выполнить однострочную команду
///    "cls"        -  Очистить буфер команд на стороне сервера
///    "read"       -  Прочитать буфер команд записанные на стороне сервера
///    "run"        -  Выполнить команды записанные в буфере на стороне сервера
///    "runline"    -  Выполнить построчно команды записанные в буфере на стороне сервера
///    "key"        -  Получить ключ сесии
///    "exit"       -  Разорвать соединение
///    "ping"       -  тестовый запрос (после него произойдёт разрыв соединения)
///    "gl"         -  показать имя  глобал в котором хранится буфер
///    "gl:^GBuff"  -  Установить имя  глобала в котором хранится буфер
///    "setapp:AppName"- Указываем название приложение из которого подключились 
///    Все остальные строки записываются в буфер  на стороне сервера.
///    </h4>
/// </pre>
/// <h4> Запуск сервера </h4> 
///  <example> ; 6006 - номер порта для соединения
///  ;"sirena" - область имен по умолчанию   
///  do ##class(%ZMSrv.Controller).StartSRV(6006,"sirena")</example>
///  
/// <h4> Остановить сервер </h4> 
///  <example>; 6006 - номер порта для соединения 
///   do ##class(%ZMSrv.Controller).StopSRV(6006) </example>
/// 
/// <h4> Проверить запущен ли сервер</h4> 
///  <example>                                         ;    IP       ,Port
///   if ##class(%ZMSrv.Controller).ExistSRV("10.100.12.21",6006)=1{
///      W "Сервер доступен" 
///   } else {
///      W "Сервер НЕ доступен " 
///   } </example>
/// <br><br><br>
/// <h4>  Пример подключения к Серверу из Cache' </h4> 
/// <example>
///   s obj=##class(%ZMSrv.Controller).%New()
///   if obj.Connect("127.0.0.1",6006,"sirena","_SYSTEM","SYS")=1 {
///      w !,obj.Send("ip")     
///      w !,obj.Send("run: w $ZU(110)")       
///      ; Наполняем буфер командами Cache'
///      d obj.Send(" for a=1:1:100 d ")       
///      d obj.Send(" .   w $JOB_"":""_a         ")      
///      d obj.Send(" .   w $c(13,10) ")     
///      w !,obj.Send("run") ; запустить выполнение команд в буфере
///      d obj.Send("cls")   ; Очистить буфер на стороне сервера 
///      w !,"SessionKey: "_obj.SessionKey
///   }else{
///      w !,"Error: "_obj.Error,!
///   }
///   d obj.DisConnect()
///   q
/// </example>
/// 
/// <h4>  Пример подключения к Серверу из Cache' </h4> 
/// <example>
///   s obj=##class(%ZMSrv.Controller).%New()
///   s obj.Host="127.0.0.1"
///   s obj.Port=6006
///   s obj.UserName="_SYSTEM"
///   s obj.UserPass="SYS"
///   s obj.NameSpace="sirena"
///   if obj.Connect()=1 {
///      w !,obj.Send("ip")     
///      w !,obj.Send("run: w $ZU(110)")       
///      ; Наполняем буфер командами Cache'
///      d obj.Send(" for a=1:1:100 d ")       
///      d obj.Send(" .   w $JOB_"":""_a         ")      
///      d obj.Send(" .   w $c(13,10) ")     
///      w !,obj.Send("run") ; запустить выполнение команд в буфере
///      d obj.Send("cls")   ; Очистить буфер на стороне сервера 
///      w !,"SessionKey: "_obj.SessionKey
///   }else{
///      w !,"Error: "_obj.Error,!
///   }
///   d obj.DisConnect()
///   q
/// </example>
/// 
///  <h4> Получение SQL запроса с удаленного сервера</h4> 
///  <example>
/// 
///  ;  Класс в кодом находится запроса
///  ;  Class Demo.Import5 {
///  ;     ClassMethod test(SqlStr) {
///  ;       s SQLobj=##class(%SQL.Statement).%New()
///  ;       d SQLobj.%Prepare(SqlStr)
///  ;       s DataSet=SQLobj.%Execute()
///  ;       s QMeta=DataSet.%GetMetaData()
///  ;     }
///  ;  }
///   s obj=##class(%ZMSrv.Controller).%New()
///   s obj.Host="ne1234"
///   s obj.Port=6006
///   s obj.UserName="_SYSTEM"
///   s obj.UserPass="SYS"
///   s obj.NameSpace="sirena"
///   if obj.Connect()=0 {  w !,"Error: "_obj.Error,! q $$$OK   }
///   ; Вызываем класс метод
///   w obj.RunClassMethod("Demo.Import5","test","select top (500) * from Contracts.EPhDogovor where 1=1 ")  
///   for  {
///       q:+obj.Send("run: w DataSet.%Next()")=0
///       w obj.Send("run: w QMeta.columns.GetAt(1).colName")_"="_obj.Send("run: w DataSet.%GetData(1)")
///   }
///   d obj.DisConnect()
/// 
/// 
///  </example>
/// <h4> Получение SQL запроса на удаленном сервере(вариант 2) </h4>
///  <example>
///            s SqlStr="select * from %SYS.ProcessQuery"
///            s obj=##class(%ZMSrv.Controller).%New()
///            ;   s obj.Host="127.0.0.1"
///            ;   s obj.Port=6006
///            ;   s obj.UserName="_SYSTEM"
///            ;   s obj.UserPass="SYS"            
///            s obj.NameSpace="SAMPLES"
///            if obj.Connect()=1 {
///                ;  s obj.TimeOut=0
///                ;  s SqlStr="select top (?) * from Contracts.EPhDogovor where 1=1  and id [ ? "
///                ;  d obj.SqlExec("",SqlStr,10,999)
///                if obj.SqlExec("",SqlStr)'=1 {   
///                   w obj.Error       
///                }else{
///                   for  {
///                       s ResNext=obj.SqlNextRaw("")
///                       q:ResNext=0
///                       if ResNext="" {
///                          w obj.Error
///                          q    
///                       }
///                       s re=obj.SqlGetRaw("")
///                       zw re ; показать объект
///                    }
///                }
///            }   
///            d obj.DisConnect()
///            q
/// 
///  </example>
/// 
///  <h4>Получить объекты из Query запроса</h4>
///  <example>
///               s obj=##class(%ZMSrv.Controller).%New()
///               ;   s obj.Host="127.0.0.1"
///               ;   s obj.Port=6006
///               ;   s obj.UserName="_SYSTEM"
///               ;   s obj.UserPass="SYS"
///                 s obj.NameSpace="SAMPLES"
///                 if obj.Connect()=1 {
///                   if obj.SqlQuery("","%Dictionary.ClassDefinition:Summary" )'=1  q
///                   for  {
///                       s resNext=obj.SqlQueryNext("")
///                       q:resNext=0
///                       if resNext="" {
///                          w "Error: "_obj.Error,!
///                          q
///                       }
///                       s re=obj.SqlQueryGet("")
///                       zw re
///                   }
///                      
///                 }else{
///                   w !,"Error: "_obj.Error,!
///                 }
///                 d obj.DisConnect()
///                 q
///  </example>
///  <h4> Получить объект по ID   </h4>
///  <example>
///       s obj=##class(%ZMSrv.Controller).%New()
///       s obj.Host="127.0.0.1"
///       s obj.Port=6006
///       s obj.UserName="_SYSTEM"
///       s obj.UserPass="SYS"
///       s obj.NameSpace="SAMPLES"
///       if obj.Connect()=1 {
///         s ExternalObject=obj.GetObject("Cinema.Film","1" )  
///         zw ExternalObject
///       }else{
///         w !,"Error: "_obj.Error,!
///       }
///       d obj.DisConnect()
///  </example>
///  <h4>Создать локально таблицу по SQL запросу во внешнюю БД и заполнить её результатом запроса </h4>
///  <example>
///          ; select * from TabDst4
///          ; --delete from TabDst4
///           s obj=##class(%ZMSrv.Controller).%New()
///           s obj.Host="127.0.0.1"
///           s obj.Port=6006
///           s obj.UserName="_SYSTEM"
///           s obj.UserPass="SYS"
///           s obj.NameSpace="SAMPLES"
///           if obj.Connect()=1 {
///               s SQLstr="select top 4 id as OldID , ID , Title, Description ,  TicketsSold from Cinema.Film"
///               s DstClassName = "User.TabDst4"
///               d obj.CreateTabFromSQL(SQLstr,DstClassName )     ; создаем таблицу
///               d obj.SqlExec("test", SQLstr) ; Делаем запрос данных  
///               s RawInd=0
///               for  {
///                  q:obj.SqlNextRaw("test")=0
///                  #DIM RecObject as  %ZEN.proxyObject =obj.SqlGetRaw("test")
///                  s RawInd=RawInd+1
///                  ; Создание записи в таблице 
///                  s oZak1=$zObjClassMethod(DstClassName,"%New")
///                  s key=""
///                  for {
///                     s key=$o(RecObject.%data(key))
///                     q:key=""
///                     continue:key11="ID"
///                     s $zObjProperty(oZak1,key11)=RecObject.%data(key)
///                     ; w RawInd_") ||"_RecObject.ID_"||"_key_"  "_RecObject.%data(key),!
///                  }
///                  s err=oZak1.%Save()
///               }
///           }else{
///             w !,"Error: "_obj.Error,!
///           }
///           d obj.DisConnect()
///           q
///  
///  </example>
///  <h4>Создаем таблицу из SQL запроса и заносим в неё данние </h4>
///  <example>
///           s obj=##class(%ZMSrv.Controller).%New()
///           s obj.Host="127.0.0.1"
///           s obj.Port=6006
///           s obj.UserName="_SYSTEM"
///           s obj.UserPass="SYS"
///           s obj.NameSpace="SAMPLES"
///           if obj.Connect()=1 {
///               s SQLstr="select top 4 id as OldID , ID , Title, Description ,  TicketsSold from Cinema.Film"
///               s DstClassName = "User.TabDst4"
///               d obj.CreateTabFromSQL(SQLstr,DstClassName )     ; создаем таблицу
///               d obj.SqlExec("test", SQLstr) ; Делаем запрос данных  
///               s RawInd=0
///               for  {
///                  q:obj.SqlNextRaw("test")=0
///                  s RawInd=RawInd+1
///                  #DIM RecObject as  %ZEN.proxyObject =obj.SqlGetRaw("test")
///                  s res=obj.AddObjectToTab(RecObject,DstClassName )  ; Добавляем объект в таблицу и получаем ID новой записи
///                  if res=0  w obj.Error,!   ; если ID равен 0 , тогда произошла ошибка в процессе записи
///                  e         w res,!
///               }
///           }else{
///             w !,"Error: "_obj.Error,!
///           }
///           d obj.DisConnect()
///           q
/// 
///  </example>
Class %ZMSrv.Controller Extends (%RegisteredObject, %CSP.Page) [ Language = cache ]
{

/// Название тэга начала получения данных
Parameter RawTag = "raw";

///   Список IP адресов , которым разрешен доступ к серверу. Список перечисляется через запятую
/// <h3>  Parameter ClientIP="127.0.0.1,192.168.1.15";</h3> 
/// <br>  Если список пуст, тогда ограничений нет, все имеют доступ.
/// <!--               localhost,   NE1234   ,  ITC434     -->
/// <!--              "127.0.0.1,10.100.12.21,10.20.29.67" -->
Parameter ClientIP;

/// Сгенерированный ключ сэсии (закодирован в Base64)
Property SessionKey As %String;

/// Имя устройства обмена данными (клиент)
Property IO As %String [ InitialExpression = "|TCP|2" ];

/// имя пользователя для авторизации
Property UserName As %String [ InitialExpression = "_SYSTEM" ];

/// Описание возникающих ошибок 
Property Error As %String [ InitialExpression = " " ];

/// Пароль пользователя()
Property UserPass As %String [ InitialExpression = "SYS" ];

/// Адрес подключения к серверу ( для клиента )
Property Host As %String [ InitialExpression = "127.0.0.1" ];

/// Порт подключения 
Property Port As %String [ InitialExpression = 6000 ];

/// Область имен, на которую необходимо переключится при клиенту при подключении
Property NameSpace As %String [ InitialExpression = {$ZU(5)} ];

/// Признак подключения к серверу
Property isConnected As %Library.Boolean [ InitialExpression = 0 ];

/// Признак кодирования исходящих команд 
/// <br> Увеличивает исходящий трафик, но перехват сообщений бесполезен, так как 
/// <br> шифрование идет с применением ключа сессии.
/// <br> 1-шифрование включено
/// <br> 0-шифрование выключено
Property isCode As %Library.Boolean [ InitialExpression = 0 ];

/// Количество символов полученные за один запрос.
Property length As %Library.Integer [ InitialExpression = 0 ];

/// Сумарное количество полученный символов с сервера
Property LengthAll As %Library.Integer [ InitialExpression = 0 ];

/// Полученая клиентом информация от сервера
Property Request;

/// Полученая клиентом информация от сервера в потоке
Property RequestSream As %Library.GlobalCharacterStream [ InitialExpression = {##class(%GlobalCharacterStream).%New()} ];

/// Отправленая информация на сервер
Property Response;

/// Время выполнения запроса
Property TimeRequest As %Library.Integer;

/// <br>  Время в секундах ожидания ответа , после выполнения кода
/// <br>  TimeOut=0  отключить таймаут
Property TimeOut As %Library.Integer [ InitialExpression = 10 ];

/// Флаг преравания работу процесса
Property Breack As %Library.Boolean [ InitialExpression = 0 ];

///  Выгрузка классов и объектов сервера
///  d ##class(%ZMSrv.Controller).ExportSrv()
ClassMethod ExportSrv(path = "")
{
   s all("%ZMSrv.Controller.CLS")=""   ;
   ; s all("%ZMSrv.Run.CLS")=""   ;
   if $l(path)=0     d $system.OBJ.Export(.all,"C:\TMP\%ZMSrv.Controller.xml")
   e  d $system.OBJ.Export(.all,path)
}

/// d ##class(%ZMSrv.Controller).ExportSrvUDL() 
ClassMethod ExportSrvUDL(path = "")
{
  if $l(path)=0  d $system.OBJ.ExportUDL("%ZMSrv.Controller.CLS", "C:\TMP\%ZMSrv.Controller_V1.cls","/diffexport") 
  e  d $system.OBJ.ExportUDL("%ZMSrv.Controller.CLS", path,"/diffexport")
}

ClassMethod OnPage() As %Status
{
    /// Порт подключения 
    s Port=6006
    if $d(%request.Data("port",1))
    {
       s Port=%request.Data("port",1)  
    }
    s NameSpace=$zu(5)
    if $d(%request.Data("namespace",1))
    {
      s NameSpace=%request.Data("namespace",1)  
    }
    if ##class(%ZMSrv.Controller).ExistSRV(,Port)'=1{
       do ##class(%ZMSrv.Controller).StartSRV(Port,NameSpace)
       w "Сервер запущен"
       Quit $$$OK
    }else{
       w "Сервер запущен"     
    }
    Quit $$$OK
}

///  Проверить доступность сервера
ClassMethod ExistSRV(HostLoc = "127.0.0.1", PortLoc = 6006) As %Boolean
{
  s res=1
  SET io="|TCP|2" 
  try { OPEN io:(HostLoc:PortLoc:"M"):5 
        IF ('$TEST) { s res=0 }
        USE io  w "ping",!,*-1
        READ key  
        use 0    
        if key="ok" s res=1
  }CATCH ErrorHandle{ 
    s res=0
  }
  CLOSE io 
  q res
}

/// Создать соединение с сервером
Method Connect(Host = "", NameSpace = "", Port = "", UserName = "", UserPass = "") As %Boolean
{
  s:Host'="" ..Host=Host
  s:NameSpace'="" ..NameSpace=NameSpace
  s:Port'="" ..Port=Port
  s:UserName'="" ..UserName=UserName
  s:UserPass'="" ..UserPass=UserPass
  if $SYSTEM.Security.Login(..UserName,..UserPass)=0 {
     s ..Error="Ошибка авторизации"
     q 0   
  }
  #define cspEncode(%k,%d)      $translate($System.Encryption.AESBase64Encode(%d,%k),"+=/"_$char(32,13,10),"_-$") 
  #define cspDecode(%k,%d)      $System.Encryption.AESBase64Decode($translate(%d,"_-$","+=/"),%k) 
  s ..isConnected=0
  SET ..IO="|TCP|2" 
  CLOSE ..IO
  OPEN ..IO:(..Host:..Port:"M"):5 
  IF ('$TEST) { 
      ; Запускаем сервер через вэб страницу
      s httpRequest=##class(%Net.HttpRequest).%New()
      s RemwebPort=80
      if $d(^%SYS("WebServer","Port")) s RemwebPort=^%SYS("WebServer","Port")
      s httpRequest.Server=..Host
      s httpRequest.Port=RemwebPort
      s className=$p(##THIS,"@",2)
      s app=$System.CSP.GetDefaultApp(..NameSpace)
      s isExistNameSpace=0
      For i=1:1:$ZU(90,0){ 
         if $l($ZU(90,2,0,i))>0 ,$ZCVT(..NameSpace,"L")=$ZCVT($ZU(90,2,0,i),"L"){
	       s isExistNameSpace=1  
	       q
         }
      }
      if isExistNameSpace=0 {
         s ..Error="Область имен "_..NameSpace_" на сервере не обнаружена."
         q 0   
      }
      if app="" {
         s ..Error="В области имен "_..NameSpace_" не определен DefaultApp."
         q 0   
      }
      s url=app_"/"_$replace(className,"%","%25")_".cls/?port="_..Port_"&namespace="_..NameSpace
      d httpRequest.Get(url)
      s retHtml= httpRequest.HttpResponse.Data.Read(32000)
      if $l(retHtml,"Сервер запущен")>1 {
         OPEN ..IO:(..Host:..Port:"M"):5 
      } else {
         s ..Error= "Web Cервис не отвечает ("_url_")"
         q 0   
      }
      IF ('$TEST) { 
         s ..Error= "Сервер не отвечает"
         Quit 0 
      }
  }
  s ^||isBreack=0
  ; Авторизация
  try {
    USE ..IO    w ..UserName,!,*-1
    READ key  READ x 
    s ..SessionKey= $System.Encryption.Base64Decode( key )
    if ..isCode=1 USE ..IO    w $$$cspEncode(..SessionKey,..UserPass),!,*-1  
    else          USE ..IO    w ..UserPass                           ,!,*-1  
    USE ..IO READ x 
    s ..UserPass=""
    if $l(x)>0 {
        USE 0  s ..Error="Ошибка авторизации"
        CLOSE ..IO     
        s ^||isBreack=1
        q
    }
    USE ..IO READ x  
  }CATCH {
    s ^||isBreack=1
    CLOSE ..IO  
  }
  q:^||isBreack=1 0
  k ^||isBreack
  // отправляем пустой запрос
  if ..isCode=1  USE ..IO w $$$cspEncode(..SessionKey,"ip"),!,*-1 READ x,x,x  USE 0
  else           USE ..IO w "ip",!,*-1 READ x,x,x  USE 0
  d ..Send("run: d $ZU(5,"""_..NameSpace_""") " )
  s ..isConnected=1
  d ..Send("setapp:"_$ZU(110))
  q ..isConnected
}

/// Отключится от сервера  
Method DisConnect()
{
  if ..isConnected=1 {
   s ..isConnected=0
    s $ZTRAP="Err"
     SET ..IO="|TCP|2" 
     ; Отклчение от сервера
     d ..Send("exit")
     CLOSE ..IO 
Err
  }
  q
}

/// Метод включения кодирования исходящих команд
Method EndodeCmdOn()
{
  if ..isConnected=1 {
    d ..Send("run: s ^||isDecodeClientCommand=1 ")     
  }
  s ..isCode=1
}

/// Метод выключения кодирования исходящих команд
Method EndodeCmdOff()
{
  if ..isConnected=1 {
    d ..Send("run: s ^||isDecodeClientCommand=0 ")     
  }
  s ..isCode=0
}

/// Прочитать результат выполнения команды с сервера
Method Read(GlobalResult = "") As %String
{
  ;     ;  s ..Breack=0   
  s ..TimeRequest=0
  s TimeStart=$p($h,",",2)
  s ..length=0
  s ..Request=""
  s ^||indTime=0
  s ^||ind=0
  if GlobalResult="" {
     for {
        USE ..IO READ ^||XTmp:1
        if ..Breack=1  {  q  }
        if ..TimeOut>0,^||indTime>..TimeOut {  q  }
        s ^||indTime=^||indTime+1
        continue:$l(^||XTmp)=0
        continue:^||XTmp="{{raw}}"
        q:^||XTmp="{{ok}}"
        s ^||indTime=0
        do ..RequestSream.WriteLine(^||XTmp)
        s ..length=..length+$l(^||XTmp)
        if ..length<32000 {
             s ^||ind=^||ind+1
             s:^||ind'=1 ..Request=..Request_$c(13,10)
              s ..Request=..Request_^||XTmp
        }
      }
      k ^||XTmp
   }else{
       s ^||XTmpInd=0
       for {
          USE ..IO 
        s ^||XTmp=""
        READ ^||XTmp:1
        if ..Breack=1  {  q  }
        if ..TimeOut>0,^||indTime>..TimeOut {  q  }
        s ^||indTime=^||indTime+1
        continue:$l(^||XTmp)=0
        continue:^||XTmp="{{raw}}"
        q:^||XTmp="{{ok}}"
        s ^||indTime=0        
        s ..length=..length+$l(^||XTmp)
        s ^||XTmpInd=^||XTmpInd+1
        s @GlobalResult@(^||XTmpInd)=^||XTmp
        s ..Request(^||XTmpInd)=^||XTmp
        do ..RequestSream.WriteLine(^||XTmp)
      }
      s @GlobalResult=^||XTmpInd
   }
   USE 0
   s ..LengthAll=..LengthAll+..length
   s ..TimeRequest=0+($p($h,",",2)-TimeStart)
   q ..Request
}

/// добавить сообщение в буфер
Method Push(cmd = "")
{
 s ..Response=cmd
 s ..Error=""
 try{
    if ..isCode=1  USE ..IO    w $$$cspEncode(..SessionKey,cmd),!,*-1   READ ^||XTmp:1
    else           USE ..IO    w cmd,!,*-1
    USE 0
 }CATCH ex{ 
    s ..Error=ex
 }
}

/// Отправить сообщение на низком уровне в открытый Socket порт
Method SocketWrite(cmd = "")
{
 s ..Response=cmd
 s ..Error=""
 q:..isConnected=0 ""   
 try{
    USE ..IO    w cmd,!,*-1
    USE 0
 }CATCH ex{ 
    s ..Error=ex
 }
}

/// Создать Socket соединение  с сервером
Method SocketConnect() As %Library.Boolean
{
  s ..isConnected=0
  SET ..IO="|TCP|2" 
  CLOSE ..IO
  OPEN ..IO:(..Host:..Port:"M"):5 
  IF ('$TEST) { s ..Error= "Сервер не отвечает" Quit 0 }
  USE ..IO    w "ok",!,*-1
  USE 0
  s ..isConnected=1
  q 1
}

Method SocketDisConnect() As %Boolean
{
  s ..isConnected=0
  SET ..IO="|TCP|2" 
  CLOSE ..IO
  USE 0
  s ..isConnected=0
  q 1
}

/// Отправить сообщение на низком уровне в открытый Socket порт
Method SocketRead() As %String
{
 q:..isConnected=0 ""   
 u ..IO READ ^||XTmp
 q ^||XTmp
 
 s ..Error=""
 s ..Request=""
 try{
   s ^||ind=0
   s ^||indTime=0
   for {
      if $d(%MApplication) d %MApplication.ProcessMessages()
      if $d(MApplication) d MApplication.ProcessMessages()
      USE ..IO READ ^||XTmp:1
      if ..Breack=1  {  q  }
      if ..TimeOut>0,^||indTime>..TimeOut {  q  }
      s ^||indTime=^||indTime+1
      continue:$l(^||XTmp)=0
      s ..Request=^||XTmp
      q
   }     
   USE 0
 }CATCH ex{ 
    s ..Error=ex
 }
 q ..Request
}

/// Синхронный запрос на сервер
Method Send(cmd = "", GlobalResult = "") As %String
{
  ;  s ..Breack=0    
  s ..TimeRequest=0
  s TimeStart=$p($h,",",2)
  s ..length=0
  s ..Response=cmd
  s res=""
  try{
    if ..isCode=1  USE ..IO w $$$cspEncode(..SessionKey,cmd),!,*-1  
    else           USE ..IO w cmd,!,*-1
 }CATCH ex{ 
    s res =ex
 }
 q:res'="" res
  ; if $e(cmd,1,1)=" "        q ""
  ; if $e(cmd,1,3)="cls"      q ""
  ; if $e(cmd,1,4)="exit"     q ""
  ; if $e(cmd,1,3)="gl:"      q ""
  ; if $e(cmd,1,7)="setapp:"  q ""
   //set RequestSream = ##class(%GlobalCharacterStream).%New()
   s ..Request=""
   s ^||ind=0
   s ^||indTime=0
   if GlobalResult="" {
      for {
       if $d(%MApplication) d %MApplication.ProcessMessages()
       if $d(MApplication) d MApplication.ProcessMessages()
        USE ..IO READ ^||XTmp:1
        if ..Breack=1  {  q  }
        if ..TimeOut>0,^||indTime>..TimeOut {  q  }
        s ^||indTime=^||indTime+1
        continue:$l(^||XTmp)=0
        continue:^||XTmp="{{raw}}"
        q:^||XTmp="{{ok}}"
        s ^||indTime=0
        do ..RequestSream.WriteLine(^||XTmp)
        s ..length=..length+$l(^||XTmp)
        if ..length<32000 {
             s ^||ind=^||ind+1
             s:^||ind'=1 ..Request=..Request_$c(13,10)
              s ..Request=..Request_^||XTmp
        }
      }
      k ^||XTmp
   }else{
       s ^||XTmpInd=0
       for {
          if $d(%MApplication) d %MApplication.ProcessMessages()
          if $d(MApplication) d MApplication.ProcessMessages()          
          USE ..IO 
          s ^||XTmp=""
          READ ^||XTmp:1
          if ..Breack=1  {  q  }
          if ..TimeOut>0,^||indTime>..TimeOut {  q  }
        s ^||indTime=^||indTime+1
        continue:$l(^||XTmp)=0
        continue:^||XTmp="{{raw}}"
        q:^||XTmp="{{ok}}"
        s ^||indTime=0
        s ..length=..length+$l(^||XTmp)
        s ^||XTmpInd=^||XTmpInd+1
        s @GlobalResult@(^||XTmpInd)=^||XTmp
        s ..Request(^||XTmpInd)=^||XTmp
        do ..RequestSream.WriteLine(^||XTmp)
      }
      s @GlobalResult=^||XTmpInd
   }
   USE 0
   s ..LengthAll=..LengthAll+..length
   s ..TimeRequest=0+($p($h,",",2)-TimeStart)
   q ..Request
   ; do ..RequestSream.Rewind()
   ; while (..RequestSream.AtEnd = 0) {
   ;   set buf = ..RequestSream.Read(30000)
   ; }
   ; d ..RequestSream.Clear()
}

/// Запуск кода класс метода на стороне сервера.
/// <br> Код локального класса выгружается на сервер в отдельную MAC программу и выполняется
/// <example>
///  s obj=##class(%ZMSrv.Controller).%New()
///  // s obj.Host="127.0.0.1"
///  s obj.Host="ne1234"
///  s obj.Port=6006
///  s obj.UserName="_SYSTEM"
///  s obj.UserPass="SYS"
///  s obj.NameSpace="sirena"
///  s obj.isCode=1
///  if obj.Connect()=1 {
///    w obj.Send("run:   w $zu(5) ")
///    w !,obj.RunClassMethod("User.test2","GetTime",$zu(5) )  
///    while (obj.RequestSream.AtEnd = 0) {
///        w obj.RequestSream.Read(30000)
///    }
///    w !,"Время выполнения:"_+obj.TimeRequest_" c."
///  }else{
///    w !,"Error: "_obj.Error,!
///  }
///  d obj.DisConnect()
///  </example>
///  Локальный класс метод
///  <example>
///   Class User.test2
///   {
///      Method GetTime(Arg1="TestArg") {
///        w $h,!
///        w Arg1,!
///      }
///   }
///  </example>
Method RunClassMethod(ClassName = "", ClassMethodName = "", %args...) As %String
{
 ; s ClassName = %args(1)
 ; s ClassMethodName =""
 ; s:$Get(%args)>1 GlobalResult = %parm(2)
     q:..isConnected=0 ""
     q:$zObjClassMethod("%CompiledClass","%ExistsId",ClassName)=0 "" 
     s tt=##class(%Dictionary.ClassDefinition).%OpenId(ClassName)
    q:'tt "" 
    s Time=0
    d ..Send("cls")
    s Time=+Time+..TimeRequest 
    for i=1:1:tt.Methods.Count() {
      continue:tt.Methods.GetAt(i).Name'=ClassMethodName
         d ..Send( "     d $ZU(5,"""_..NameSpace_""") " )   
         if $l(tt.Methods.GetAt(i).FormalSpec)>0 {
           s arg=tt.Methods.GetAt(i).FormalSpec
           for indArg=1:1:$l(arg,","){
               s oneArg= $p(arg,",",indArg) 
               s oneArgNam=$p(oneArg,"=",1)
               s oneArgVal=""
               s:$l( $p(oneArg,"=",2))>0 oneArgVal=$p(oneArg,"=",2)
               
               if ($Get(%args)>indArg||$Get(%args)=indArg) {
                  d ..Send( "    s "_oneArgNam_"="""_%args(1)_""" " )   
               }else{
                    
                  d ..Send( "    s "_oneArgNam_"="_oneArgVal_" " )   
               }
           }
         }
       while 'tt.Methods.GetAt(i).Implementation.AtEnd  {
          s tmp= tt.Methods.GetAt(i).Implementation.ReadLine()
          d ..Send(tmp)  
          s Time=+Time+..TimeRequest     
       }
    }
     s tt=""
     s res=..Send("run")
     s Time=+Time+..TimeRequest   
     d ..Send("cls")
     s Time=+Time+..TimeRequest     
     s ..TimeRequest=+Time
     k Time
     q res
}

/// Уничтожение Старых зависших сесий и фрагментов кода
ClassMethod KillDedSession()
{
     s Key=""
     for  { s Key=$o(^%cspSession(Key))  
       q:Key=""
       continue:$l(Key,"@")=1
       // s jobId=$p(Key,"@",2)
       s jobId=$Lg(^%cspSession(Key),18)
       continue:jobId=0
       continue:jobId=$job  
       // Дата изменения состояния
      s DTKill=$Lg(^%cspSession(Key),19)
      if DTKill'=-1 { // Если включено ограничение времени, тогда по истечению этого
          // времени закрываем процесс, и удалям  сессию
          s datK=$p(DTKill,",",1)
          s timK=$p(DTKill,",",2)
          s datN=$p($h,",",1)
          s timN=$p($h,",",2)
          if ((datN-datK)+(timN-timK))<0{
               d $ZU(4,jobId)
               k ^%cspSession(Key)  
          }
      }
      s SQLobj=##class(%SQL.Statement).%New()
      d SQLobj.%Prepare("select count(Pid) from %SYS.ProcessQuery where  (Pid="_jobId_")  ")
      s DataSet=SQLobj.%Execute()
      while DataSet.%Next() {
          if DataSet.%GetData(1)=0 {
            k ^%cspSession(Key)   
            Do ##class(%Routine).Delete("MSrvTMPFragment"_jobId_".MAC")
          }
       }
       s SQLobj=""  k SQLobj
   }
}

/// Выгрузить контроллер в XML файл
ClassMethod Export(path = "")
{
   k all
   s all("%ZMSrv.Controller.CLS")=""
   s all("%ZMSrv.Run.CLS")=""
   if $l(path)=0     d $system.OBJ.Export(.all,"ZMSrv("_$REPLACE($zd(+$h,4),"/","-")_").xml")
   e  d $system.OBJ.Export(.all,path)
   k all
   q
}

/// Остоновить сервер
ClassMethod StopSRV(port = 6006)
{
  SET port = $G(port)
  if $l(port)'=0  d
  .  s ^%MSrvKill(port)=1 
  .  d ##class(%ZMSrv.Controller).ExistSRV("127.0.0.1",port)
  .  w !,"Server ^%MSrv("_port_") stoped.." 
  .  k ^%MSrv("config",port)
  d ..killTempRutine()
  q
}

/// Запустить сервер
ClassMethod StartSRV(port = 6006, DefNameSpace = "")
{
     s:DefNameSpace="" DefNameSpace=$ZU(5)
     d ..killTempRutine()
     w ! ,"MSrv сервер v0.1"
     w ! ,"Автор: Мясников Иван Александрович"
     w ! ,"Email: Miacom@mail.ru"
     w !
     ; w DefNameSpace,!
     ;  if $p($h,",",1)>(63991+60+60) w !,"Льготный период использования закончился. Обратитесь к автору за продлением.",!
  SET port = $G(port)
  if ##class(%ZMSrv.Controller).ExistSRV("127.0.0.1",port)=1 {
       s ^%MSrvKill(port)="1"
       d ##class(%ZMSrv.Controller).ExistSRV("127.0.0.1",port)
  }
  k ^%MSrvKill(port)
  job ..startJob(port,DefNameSpace)
  d $ZU(5,DefNameSpace)
  q
}

/// Паралельный поток работы сервера
ClassMethod startJob(port, DefNameSpace)
{
  s ^%MSrv("config",port,"NameSpace")=DefNameSpace     
  s ^%MSrv("config",port,"RunDate")=$h
  s ^%MSrv("config",port,"job")=$JOB
  d $ZU(5,DefNameSpace)
  k ^RunMSrv  
  SET dev="|TCP|1"
  OPEN dev:(:port:"MA"):200
  s inData=""
  s indSrv=0
  For  USE dev READ inData q:($d(^%MSrvKill(port)))  Do:$T
  . Use dev
  . Job ..childVar(port):(:17::) ; Concurrent server bit is on
  . If $ZCHILD=0 w " Server can't create new JOB!"
  Close dev
  k ^%MSrvKill(port)
  USE 0
  w "server stoped",!
  d ..killTempRutine()
  Quit
}

/// обработчик клиентских запросов
ClassMethod childVar(port)
{
 #define cspEncode(%k,%d)      $translate($System.Encryption.AESBase64Encode(%d,%k),"+=/"_$char(32,13,10),"_-$") 
 #define cspDecode(%k,%d)      $System.Encryption.AESBase64Decode($translate(%d,"_-$","+=/"),%k) 
 s ^||numPac=0
 s ^||isCloseChaild=0
 s ^||SocketTempIndex=0
 s ^||NameSpace=""
 s ^||teg=..#RawTag
 USE $ZUTIL(53):(::"M")
 s ^||I=$ZU(111,0)
 s ^||ip=$A(^||I,1)_"."_$A(^||I,2)_"."_$A(^||I,3)_"."_$A(^||I,4)_":"_($A(^||I,5)*256+$A(^||I,6))
 /// Проверка IP адреса в списке разрешений на доступ
  if $l(..#ClientIP)>0 {
     s ip=$A(^||I,1)_"."_$A(^||I,2)_"."_$A(^||I,3)_"."_$A(^||I,4)
     s IsConnectOk=0
     for ind=1:1:$L(..#ClientIP,","){   if $p(..#ClientIP,",",ind)=ip { s IsConnectOk=1 q }}    
     if IsConnectOk=0 { USE $ZUTIL(53):(::"M") d ..startCmd()  w "Доступ запрещен" d ..stopCmd()  Close $ZUTIL(53)   q }
     k ip,i,IsConnectOk
  } 
  s ^||ipKey="Connect@"_$p(^||ip,":",1)_":"_$job
  ; s pass=^||ipKey,HashPwd="" 
  ; F ix489=1:1:7 { S HashPwd=HashPwd_$ZCRC(pass,ix489)}  
  ; s ^||ipKey=HashPwd
  if ##class(%CSP.Session).%ExistsId(^||ipKey)=1{
    s %session=##class(%CSP.Session).%OpenId(^||ipKey)
  }else{
    s %session=##class(%CSP.Session).%New(^||ipKey)
  }
  s %session.ProcessId="%ZMSrv.Controller: job"_$job_" "
  S %session.AppTimeout = 3600*24
  s ^||IsLogOn=0
  d %session.%Save()
  // Приложение 
  s $LI(^%cspSession(^||ipKey),15)="%ZMSrv.Controller"
  //ID процесса
  s $LI(^%cspSession(^||ipKey),18)=$job
  
 // Дата изменения статуса 
 // s $LI(^%cspSession(^||ipKey),18)=$h
 // Дата Закрытия процесса 
 // s $LI(^%cspSession(^||ipKey),19)=$h
 
 d ..setProcInfo("Подключение",20) 
 // Идентификатор лицензии 
 // s $LI(^%cspSession(^||ipKey),12)="22222222222"
 // Приложение 
 // s $LI(^%cspSession(^||ipKey),15)="22222222222"
 // Пользователь 
 // s $LI(^%cspSession(^||ipKey),16)=$LB("ddddddddd")
 // Идентификатор процесса 
 // s $LI(^%cspSession(^||ipKey),32)="ddddddddddddd"
 
 // Уничтожение зависших сесий
  d ..KillDedSession()
 //---------------------------
  
  
 s ^||ind=0
 s ^||UserName="UnknownUser"
 s %gl="^MSrv"
 s ^||isDecodeClientCommand=0
 For  Q:((^||isCloseChaild=1)||($T=1))  d
 .  if $T=1 s ^||isCloseChaild=1
 .  if ##class(%CSP.Session).%ExistsId(^||ipKey)=0 s ^||isCloseChaild=1 q
 .  USE $ZUTIL(53):(::"M")
 .  READ ^||inData:1
 .  if $l(^||inData)=0 q
 .  ; s ^debug(^||ind)=^||inData
 .  ; Декодируем если необходимо
 .  TRY{ if ^||isDecodeClientCommand=1 s ^||inData=$$$cspDecode(%session.Key,^||inData)}CATCH {}
 .  s ^||inData= $ZCVT(^||inData,"I","URL")
 .  ; s ^||inData= $ZCVT(^||inData,"I","UTF8")
 .  s ^||ind=^||ind+1
 .  ; Авторизация 
 .  if ^||ind=1  d ..setProcInfo("Авторизация",20)  if ^||inData="ping" { w "ok" d ..stopCmd()  s ^||isCloseChaild=1 q }   s ^||UserName=^||inData  s ^||inData=""  w $System.Encryption.Base64Encode(%session.Key)  d ..stopCmd()  q
 .  if ^||ind=2  d ; Авторизация 
 .  .    s ^||UserPass=^||inData
 .  .    
 .  .    if $p(^||ip,":",1)="127.0.0.1" {  
 .  .       s ^||IsLogOn=1
 .  .    } else {
 .  .       if $SYSTEM.Security.Login(^||UserName,^||UserPass)=0  d 
 .  .       .   TRY{  s ^||UserPass=$$$cspDecode(%session.Key,^||inData) }CATCH { s ^||UserPass="" }
 .  .       .   if $SYSTEM.Security.Login(^||UserName,^||UserPass)=0  d
 .  .       .   .  s ^||isCloseChaild=1 
 .  .       .   .  w "Login error"  d ..stopCmd() 
 .  .       .   .  q  
 .  .       .   e  d  
 .  .       .   .  s ^||isDecodeClientCommand=1 
 .  .    }
 .  .    s ^||IsLogOn=1
 .  .    d:$d(^%MSrv("config",port,"NameSpace")) $zu(5,^%MSrv("config",port,"NameSpace"))
 .  .    // Пользователь 
 .  .    s $LI(^%cspSession(^||ipKey),16)=$LB(^||UserName)
 .  .    // Идентификатор лицензии 
 .  .    s $LI(^%cspSession(^||ipKey),12)=^||UserName_"@"_$JOB
 .  .
 .  .    k ^||UserPass
 .  .    s ^||inData=""
 .  .   
 .  .    q
 .  
 .  ; s ^debug(^||ind)=^||inData
 .  s ^||isGotoNextReadLine=0
 .  TRY{
 .      if ^||inData="exit" s ^||isGotoNextReadLine=1  d ..setProcInfo("Выход из системы",10)  d ..startCmd()  w "Disconnect"      d ..stopCmd()  s ^||isCloseChaild=1 q ; выход из этого сианса
 .      if ^||inData="ip" s ^||isGotoNextReadLine=1    d ..setProcInfo("Получение IP адрес клиента",-1)  d ..startCmd()  w ^||ip   d ..stopCmd()  q
 .      if ^||inData="job" s ^||isGotoNextReadLine=1   d ..setProcInfo("Получение ID процесса клиента",-1) d ..startCmd()  w $job d ..stopCmd()  q
 .      if ^||inData="key" s ^||isGotoNextReadLine=1   d ..setProcInfo("Полуение ключа сесии",-1) d ..startCmd()  w $System.Encryption.Base64Encode(%session.Key) d ..stopCmd()  q
 .      if $l(^||inData,"run:")=2 , $l($p(^||inData,"run:",1))=0 ,$l($p(^||inData,"run:",2))>0   s ^||isGotoNextReadLine=1   d
 .      .  d ..setProcInfo("Однострочный код"_^||inData,-1)  d ..startCmd()  d ..runOneCode($p(^||inData,"run:",2))  d ..stopCmd()    q 
 .  
 .   ;   if ^||inData="teg" s ^||isGotoNextReadLine=1   s ^||teg="raw"   d ..stopCmd()  q
 .   ;   if $l(^||inData,"teg:")=2 , $l($p(^||inData,"teg:",1))=0 ,$l($p(^||inData,"teg:",2))>0   s ^||isGotoNextReadLine=1   d
 .   ;   .   s ^||teg=$p(^||inData,"teg:",2)  d ..stopCmd()    
 .   ;   .   d ..setProcInfo("Тэг изменен "_^||teg,10) 
 .   ;   .   q
 .
 .      if ^||inData="read"     s ^||isGotoNextReadLine=1  d ..setProcInfo("Чтение буфера",-1)      d ..startCmd()  d ..readGlobal()    d ..stopCmd()   q
 .      if ^||inData="runline"  s ^||isGotoNextReadLine=1  d ..setProcInfo("Выполнение построчно кманды буфера",-1)    d ..startCmd()  d ..runBufferLine() d ..stopCmd()   q
 .      if ^||inData="run"      s ^||isGotoNextReadLine=1  d ..setProcInfo("Выполнение кода всего буфера",-1)    d ..startCmd()  d ..run()           d ..stopCmd()   q
 .      if ^||inData="cls"      s ^||isGotoNextReadLine=1  d ..setProcInfo("Очистка буфер",-1)    d ..startCmd()  d ..clsGlobal()         d ..stopCmd()   q
 .      if ^||inData="gl"       s ^||isGotoNextReadLine=1  d ..setProcInfo("Чтение имени глобала буфера",-1)    d ..startCmd()  w %gl     d ..stopCmd()   q
 .      if $l(^||inData,"gl:")=2 , $l($p(^||inData,"gl:",1))=0 ,$l($p(^||inData,"gl:",2))>0  if $p(^||inData,"gl:",2)="" {s ^||inData=^||inData_..#RawTag }  s %gl= $p(^||inData,"gl:",2)   d ..stopCmd()  s ^||isGotoNextReadLine=1   d
 .      if $l(^||inData,"setapp:")=2 , $l($p(^||inData,"setapp:",1))=0 ,$l($p(^||inData,"setapp:",2))>0  if $p(^||inData,"setapp:",2)="" { s $LI(^%cspSession(^||ipKey),15)=$p(^||inData,"setapp:",2) }    d ..stopCmd()  s ^||isGotoNextReadLine=1   d
 .      
 . 
 .  }CATCH ErrorHandle{ 
 .      ; s ErrorHandle.Location=""
 .      zw ErrorHandle
 .      d ..stopCmd() 
 .  } 
 .   q:^||isGotoNextReadLine=1
 .   d ..setProcInfo("Запись строк в буфер",-1)
 .   if '$d(@%gl@($job))  s @%gl@($job)=0
 .   s @%gl@($job)=@%gl@($job)+1
 .   s @%gl@($job,@%gl@($job))=^||inData
 .   d ..stopCmd()
 .
 USE $ZUTIL(53):(::"M")
 s I=$ZU(111,0)
 s ip=$A(I,1)_"."_$A(I,2)_"."_$A(I,3)_"."_$A(I,4)
 s ipKey="Connect@"_$p(ip,":",1)_":"_$job
 k ^%cspSession(ipKey)
 if ^||IsLogOn=0  w "Login error"  d ..stopCmd() 
 ; d ##class(%CSP.Session).%DeleteId(^||ipKey)
 k @%gl@($job)
 k ^SPOOL($job)
 Do ##class(%Routine).Delete("MSrvTMPFragment"_$JOB_".MAC")
 s ^||isCloseChaild=0
 Close $ZUTIL(53)
 zn "%SYS"
 q
}

/// Установить идентификатор процесса
ClassMethod setProcInfo(Text = "", TimeKillProc = -1)
{
   q:'$d(^%cspSession(^||ipKey))
   // Идентификатор процесса 
   s $LI(^%cspSession(^||ipKey),32)=Text
   //Дата уничтожения процесса (если -1 тогда бесконечность)
   if TimeKillProc=-1 {
      s $LI(^%cspSession(^||ipKey),19)=TimeKillProc
   }else{
       s dat=$p($h,",",1)
       s timTmp=$p($h,",",2)+TimeKillProc
       if timTmp>86399 { 
           s dat=dat+1
           s tim=timTmp-86399
       }else{
          s tim=timTmp
       }
      s $LI(^%cspSession(^||ipKey),19)=dat_","_tim
      k timTmp,tim,dat
   }
}

/// Чтение буфера
ClassMethod readGlobal()
{
   if '$d(@%gl@($job))    q
   s ^||indBuff=""
   f   s ^||indBuff=$o(@%gl@($job,^||indBuff))   q:^||indBuff=""   d
   .   w @%gl@($job,^||indBuff),!
   q
}

/// Очистка буфера 
ClassMethod clsGlobal()
{
   k @%gl@($job)
   q
}

/// запустит код из буфера как MAC программу   
ClassMethod run()
{
 
      if '$d(@%gl@($job))    q
      DO $SYSTEM.Process.NullSubscripts(0)
      s ^||indBuff=""
      s routine =##class(%Routine).%New("MSrvTMPFragment"_$JOB_"")
      Do routine.WriteLine($c(13,10)_" ; d ^MSrvTMPFragment"_$JOB)
      f   s ^||indBuff=$o(@%gl@($job,^||indBuff))   q:^||indBuff=""   d
      .    Do routine.Write($c(13,10)_@%gl@($job,^||indBuff))
      Do routine.WriteLine($c(13,10)_"  q ")
      Do routine.Save() ;
      k ^SPOOL($JOB)
      O 2:($job) 
      U 2:($job)
      s $ZTRAP="ErrorCompilMacProgramm"
      Do routine.Compile() ;
      c 2:($job)  
      k ^SPOOL($JOB)
      Do routine.%Close()
      USE $ZUTIL(53):(::"M")
      TRY {
        d ..setProcInfo("Запуск программы:"_" d ^MSrvTMPFragment"_$JOB,-1)
        x " d ^MSrvTMPFragment"_$JOB 
        c 2:($job)  
        Do routine.Delete("MSrvTMPFragment"_$JOB_".MAC")
      } CATCH ErrorHandle { 
          w "Error:",$c(13,10)
          w " NameSpace:"_$zu(5),$c(13,10)
          w $ZTRAP,$c(13,10)
          w $ESTACK,$c(13,10)
          w $ECODE,$c(13,10)
          w $ZERROR,$c(13,10)
          ; s ErrorHandle.Location=" d ^MSrvTMPFragment"_$JOB 
          zw ErrorHandle
      }
      q
ErrorCompilMacProgramm
      USE $ZUTIL(53):(::"M")
      w " NameSpace:"_$zu(5),$c(13,10)
      w $ZTRAP,$c(13,10)
      w $ESTACK,$c(13,10)
      w $ECODE,$c(13,10)
      w $ZERROR,$c(13,10)
      c 2:($job)  
      d ..setProcInfo("Ошибка прграммы:"_" d ^MSrvTMPFragment"_$JOB,-1)
     // Do routine.Delete("MSrvTMPFragment"_$JOB_".MAC")
      q
}

/// запустить код из буфера построчно   
ClassMethod runBufferLine()
{
      if '$d(@%gl@($job))  w "empty"  q
      s ^||indBuff=""
      f   s ^||indBuff=$o(@%gl@($job,^||indBuff))   q:^||indBuff=""   d
      .    s $ZTRAP="ztrunBufferLine"
      .    USE $ZUTIL(53):(::"M")
      .    TRY {
       .         d ..setProcInfo("Cod:"_@%gl@($job,^||indBuff),-1  )
       .         x @%gl@($job,^||indBuff)  
      .     } CATCH ErrorHandle {  
      .           w "Error:",$c(13,10)
      .         w " NameSpace:"_$zu(5),$c(13,10)
      .         w $ZTRAP,$c(13,10)
      .         w $ESTACK,$c(13,10)
      .         w $ECODE,$c(13,10)
      .         w $ZERROR,$c(13,10)
      .         ; s ErrorHandle.Location=@%gl@($job,^||indBuff)
      .         zw ErrorHandle
      .     }
      q
ztrunBufferLine      
      USE $ZUTIL(53):(::"M")
      w " NameSpace:"_$zu(5),!
      w " NumLine:"_^||indBuff,!
      w " TextCode:"_@%gl@($job,^||indBuff),!
      w $ZERROR,! 
      q
}

///  запуск кода в в одной строке строке
///  ;run:  w $h
ClassMethod runOneCode(cod)
{
    if $l(cod)=0  q
    s $ZTRAP="ztrunOneCode"
    USE $ZUTIL(53):(::"M")
    TRY {
         d ..setProcInfo("Cod:"_cod ,-1)
        x cod
    } CATCH ErrorHandle {  
       w "Error:",$c(13,10)
       w " NameSpace:"_$zu(5),$c(13,10)
       w $ZTRAP,$c(13,10)
       w $ESTACK,$c(13,10)
       w $ECODE,$c(13,10)
       w $ZERROR,$c(13,10)
       ; s ErrorHandle.Location=cod
       zw ErrorHandle
     }
    q
ztrunOneCode
    w " NameSpace:"_$zu(5),!
    w cod,!
    w $ZERROR,! 
    d ..setProcInfo("ErrorCod:"_cod ,-1 )
    q
}

/// Создание Тэга начало ответа
ClassMethod startCmd()
{
  USE $ZUTIL(53):(::"M")
  w "{{"_^||teg_"}}",!,*-2
  q
}

/// создание тэга конец ответа
ClassMethod stopCmd()
{
  USE $ZUTIL(53):(::"M")
  w !,"{{ok}}",*-2,!
  q
}

/// Метод удаления временных программ
/// <br> Все MAC программы с именем "MSrvTMPFragment..." буду удалены
ClassMethod killTempRutine()
{
   s OldNameSpace=$zu(5) 
   For i=1:1:$ZU(90,0)    s tmp=$ZU(90,2,0,i) if $l(tmp)>0  Set nslist(tmp)=""
   s nameSpase=""
   For    Set nameSpase=$O(nslist(nameSpase))     Quit:nameSpase=""   d
   .  ; w nameSpase,!
   .  d $ZU(5,nameSpase)
   .  s res=##class(%ResultSet).%New("%Library.Routine:RoutineList")
   .  d res.Execute("*.MAC,*.INC,*.INT")
   .  f  q:'res.Next()     d
   .  .  s isFound=0 , resText=""
   .  .  s Routine=res.Get("Name")
   .  .  if $l(Routine,"MSrvTMPFragment")>1 d
   .  .   .   w Routine,!
   .  .   .   s routine =##class(%Routine).%New()
   .  .   .   Do routine.Delete(Routine)
   d $ZU(5,OldNameSpace)
}

Method GetObject(ClassName = "", ID = "") As %Library.DataType
{
   if $d(%MApplication) d %MApplication.ProcessMessages()
   if $d(MApplication)  d MApplication.ProcessMessages()
   s ..Error=""
   if ..Send("run:  w $zObjClassMethod(""%CompiledClass"",""%ExistsId"","_ClassName_") ")=0  s ..Error="Ошибка: Класс "_ClassName_" не обнаруженн. "  q ""
   if $zObjClassMethod("%CompiledClass","%ExistsId",ClassName)=1 {
       do ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(..Send("run:   s GetObjectOne=##class("""_ClassName_""").%OpenId("""_ID_""")    do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(GetObjectOne,,,""aelotw"")   "),ClassName,.override,1)
   }else{  
      do ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(..Send("run:   s GetObjectOne=##class("""_ClassName_""").%OpenId("""_ID_""")    do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(GetObjectOne,,,""aelotw"")    "),,.override,1)
   }
   d ..Push("run:   s GetObjectOne=""    ")
   q override
}

/// Получить значение указанного поля
Method SqlGetAt(SqlObjectName = "", PoleName = "") As %String
{
  s ..Error=""
  if $d(%MApplication) d %MApplication.ProcessMessages()
  if $d(MApplication) d MApplication.ProcessMessages()
  if SqlObjectName="" s SqlObjectName="DataSet"
  if PoleName="" {
     s ..Error="Не указано имя поля, для чтения результата запроса"
     q ""
  }
  q ..Send("run:  w "_SqlObjectName_".%Get("""_PoleName_""") ")
}

/// Получить строку записей в из резултата SQL запроса
/// Если возвращается значение -1 , значит произошла ошибка при инициализации объекта
Method SqlGetRaw(SqlObjectName = "") As %ZEN.proxyObject
{
  s ..Error=""
  if $d(%MApplication) d %MApplication.ProcessMessages()
  if $d(MApplication) d MApplication.ProcessMessages()
  if SqlObjectName="" s SqlObjectName="DataSet"
     s ^||rawTxtSqlGetRaw=..Send("run:  for ColNum=1:1:Q"_SqlObjectName_".columnCount { s val="_SqlObjectName_".%GetData(ColNum) s nam=Q"_SqlObjectName_".columns.GetAt(ColNum).colName   w $ZCVT(nam,""O"",""JS"")_$c(9)_$ZCVT(val,""O"",""JS"")_""{{RAW}}""   }")
     s arr=##class(%ZEN.proxyObject).%New()
     ; s aux=##class(%ArrayOfDataTypes).%New() 
     for indSqlGetRaw=1:1:$l(^||rawTxtSqlGetRaw,"{{RAW}}") {
         s ^||SqlGetRawraw=$p(^||rawTxtSqlGetRaw,"{{RAW}}",indSqlGetRaw)
         continue:$l(^||SqlGetRawraw)=0
         s ^||namSqlGetRaw=$zcvt(  $p(^||SqlGetRawraw,$c(9),1) ,"I","JS")
         s ^||valSqlGetRaw=$zcvt(  $p(^||SqlGetRawraw,$c(9),2) ,"I","JS")
         try {
           s arr.%data(^||namSqlGetRaw)=^||valSqlGetRaw
         }CATCH ErrorHandle{ 
           s ..Error=ErrorHandle
           s arr=-1
           q
         }  
     }
  
  q arr
}

/// Переключить запись в таблице на следующую после  выполненого SQL запроса
Method SqlNextRaw(SqlObjectName = "") As %Boolean
{
  s ..Error=""
  if $d(%MApplication) d %MApplication.ProcessMessages()
  if $d(MApplication) d MApplication.ProcessMessages()
  if SqlObjectName="" s SqlObjectName="DataSet"
  s ^||resSqlNextRaw=..Send("run: try {  w "_SqlObjectName_".%Next()  }CATCH ErrorHandle{  zw ErrorHandle }")
  if ^||resSqlNextRaw'="0",^||resSqlNextRaw'="1" {
    s ..Error=^||resSqlNextRaw
    q ""
  }
  s ^||resSqlNextRaw=+^||resSqlNextRaw
  q ^||resSqlNextRaw
}

///  Выполнить SQL запрос на удаленном сервере
Method SqlExec(SqlObjectName = "", SqlStr, %parm...) As %Library.Boolean
{
  if $d(%MApplication) d %MApplication.ProcessMessages()
  if $d(MApplication) d MApplication.ProcessMessages()
  if SqlObjectName="" s SqlObjectName="DataSet"
  d ..Send("run:   s SqlStr="""_SqlStr_"""        ")
  d ..Send("run:   s SQL"_SqlObjectName_"=##class(%SQL.Statement).%New()  ")
  d ..Send("run:   s qStatus"_SqlObjectName_" = SQL"_SqlObjectName_".%Prepare(.SqlStr)      ")
  s resQuery=..Send("run:   if qStatus"_SqlObjectName_"'=1 {DO $System.Status.DisplayError(qStatus"_SqlObjectName_")    }else { w 1}    ")
  if resQuery'=1{
     s ..Error=resQuery
     k resQuery                  
     q 0    
  }
  // Method SqlExec(     SqlStr,   %parm...)
   s ^||srgTxt=""
   for tPtr = 1:1:$Get(%parm) {
      s:tPtr'=1 ^||srgTxt=^||srgTxt_","
      d ..Send("   s ArgOne"_tPtr_"="_%parm(tPtr)_"    ")
      s ^||srgTxt=^||srgTxt_"ArgOne"_tPtr_" "
   }
   d ..Send("run:   s "_SqlObjectName_"=SQL"_SqlObjectName_".%Execute("_^||srgTxt_")    ")
   d ..Send("run:   s Q"_SqlObjectName_"="_SqlObjectName_".%GetMetaData() ")
   q 1
  // w ..Read()
}

/// / Получить объект из записи SQL  Query на удаленном сервере
Method SqlQueryGet(SqlObjectName = "") As %ZEN.proxyObject
{
    s ..Error=""  
    if $d(%MApplication) d %MApplication.ProcessMessages()
    if $d(MApplication) d MApplication.ProcessMessages()
    if SqlObjectName="" s SqlObjectName="QDataSet"
    s ClassName=..Send("run:   w ^||"_SqlObjectName_"ClassName   ")
    if ..Send("run:   w $d("_SqlObjectName_".Get(""ID""))   ")=1 {
       d ..Send("    s GetSqlQueryObject"_SqlObjectName_"=$zObjClassMethod(^||"_SqlObjectName_"ClassName,""%OpenId"",query.Get(""ID"") )  ")
       d ..Send("    do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(GetSqlQueryObject"_SqlObjectName_",,,""aelotw"")    ")
       if $zObjClassMethod("%CompiledClass","%ExistsId",ClassName)=1 {
          do ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(..Send("run"),ClassName,.override,1)
       }else{  
          do ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(..Send("run"),,.override,1)
       }
    }else{
       s ^||rawTxtSqlGetRaw=..Send("run:   s IndexData=""""   for {  s IndexData=$o("_SqlObjectName_".Data(IndexData))   q:IndexData=""""  s val="_SqlObjectName_".Data(IndexData) s nam=IndexData   w $ZCVT(nam,""O"",""JS"")_$c(9)_$ZCVT(val,""O"",""JS"")_""{{RAW}}""   }")
       s override=##class(%ZEN.proxyObject).%New()
       for indSqlGetRaw=1:1:$l(^||rawTxtSqlGetRaw,"{{RAW}}") {
           s ^||SqlGetRawraw=$p(^||rawTxtSqlGetRaw,"{{RAW}}",indSqlGetRaw)
           continue:$l(^||SqlGetRawraw)=0
           s ^||namSqlGetRaw=$zcvt(  $p(^||SqlGetRawraw,$c(9),1) ,"I","JS")
           s ^||valSqlGetRaw=$zcvt(  $p(^||SqlGetRawraw,$c(9),2) ,"I","JS")
           s override.%data(^||namSqlGetRaw)=^||valSqlGetRaw
           k ^||namSqlGetRaw,^||valSqlGetRaw
       }
    }
    q override
}

/// Переключится к следующей записи SQL  Query на удаленном сервере
Method SqlQueryNext(SqlObjectName = "") As %Library.Boolean
{
  s ..Error=""
  if $d(%MApplication) d %MApplication.ProcessMessages()
  if $d(MApplication) d MApplication.ProcessMessages()
  if SqlObjectName="" s SqlObjectName="QDataSet"
  s ^||resSqlNextRaw=..Send("run:  try {   w "_SqlObjectName_".Next()  }CATCH ErrorHandle{  zw ErrorHandle } ")
  if ^||resSqlNextRaw'="1",^||resSqlNextRaw'="0"{
     s ..Error=^||resSqlNextRaw
     q ""
  }
  q +^||resSqlNextRaw
}

/// Выполнить SQL  Query запрос на удаленном сервере
Method SqlQuery(SqlObjectName = "", ClassQuery, %parm...) As %Library.Boolean
{
   s ..Error=""
   if $d(%MApplication) d %MApplication.ProcessMessages()
   if $d(MApplication) d MApplication.ProcessMessages()
   if SqlObjectName="" s SqlObjectName="QDataSet"
   s ^||srgTxt=""
   for tPtr = 1:1:$Get(%parm) {
      s:tPtr'=1 ^||srgTxt=^||srgTxt_","
      d ..Send("run:   s ArgOne"_tPtr_"="_%parm(tPtr)_"        ")
      s ^||srgTxt=^||srgTxt_"ArgOne"_tPtr_" "
   }
   s ClassName=$p(ClassQuery,":",1)
   d ..Send("run:  s ^||"_SqlObjectName_"ClassName="""_ClassName_"""    ")
   d ..Send("run:  s "_SqlObjectName_"=##class(%ResultSet).%New("""_ClassQuery_""" )  ")
   s ResQuery=..Send("run:   try {  w "_SqlObjectName_".Execute("_^||srgTxt_") }CATCH ErrorHandle{ zw ErrorHandle  } ")
   if ResQuery'="1" {
       s ..Error=ResQuery
       q 0 
   }
   q 1
  /* 
    s ClassQuery="Cinema.Show:ShowTimes"
    s ClassName=$p(ClassQuery,":",1)
    s query=##class(%ResultSet).%New(ClassQuery)
     d query.Execute(1)
     while query.Next() {
          s id=query.Get("ID")
          s obj=$zObjClassMethod(ClassName,"%OpenId",id)
        do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(obj,,,"aelotw")   
     }
     d query.Close()
     s query=""
  */
}

/// Метод получения данных с удаленной БД , создания  локальной таблицы, и записи результата запроса в созданную таблицу
Method InsertSQLTab(SQLstr = "", DstClassName = "", %parm...) As %Library.Boolean
{
   d ..CreateTabFromSQL(SQLstr,DstClassName )     ; создаем таблицу
   d ..SqlExec("", SQLstr, %parm...) ; Делаем запрос данных  
   for  {
       if $d(%MApplication) d %MApplication.ProcessMessages()
       if $d(MApplication) d MApplication.ProcessMessages()
       q:..SqlNextRaw("")=0
       s RecObject=..SqlGetRaw("")
       s res=..AddObjectToTab(RecObject,DstClassName )  ; Добавляем объект в таблицу получаем ID новой записи
       if res=0  w ..Error,!
       e         w res,!
   }
}

/// Метод создания таблицы из SQL запроса
///            s obj=##class(%ZMSrv.Controller).%New()
///            s obj.Host="127.0.0.1"
///            s obj.Port=6006
///            s obj.UserName="_SYSTEM"
///            s obj.UserPass="SYS"
///            s obj.NameSpace="SAMPLES"
///            if obj.Connect()=1 {
///               d obj.CreatTabFromSQL("select * from Cinema.Film", "User.TabDst3")
///            }else{
///               w !,"Error: "_obj.Error,!
///            }
///            d obj.DisConnect()
Method CreateTabFromSQL(SQLstr = "", DstClassName = "") As %Library.Boolean
{
    q:DstClassName=""  
    q:SQLstr=""
    s ..Error=""
    d ..Send("cls") 
    d ..Send("run:     s DstClassName="""_DstClassName_"""         ")
    d ..Send("run:     s SQLstr="""_SQLstr_"""                     ")
    d ..Send("run:     SET rset = ##class(%SQL.Statement).%New()   ")
    d ..Send("run:     SET qStatus = rset.%Prepare(SQLstr)         ")
    s ResSqlQuery=..Send("run:     w qStatus                       ")
    if ResSqlQuery'=1 {
        s ..Error=..Send("run:  w ##class(%Status).LogicalToOdbc(qStatus)   ")
        q 0
    }
    
     ; Do:$zObjClassMethod("%CompiledClass","%ExistsId",DstClassName)=1 $system.OBJ.Delete(DstClassName)    
     if $zObjClassMethod("%CompiledClass","%ExistsId",DstClassName)=0
     {
        s tt=##class(%Dictionary.ClassDefinition).%New(DstClassName)
        s tt.Super="%Library.Persistent"
        s tt.Description=""
     }else{
        s tt=##class(%Dictionary.ClassDefinition).%OpenId(DstClassName)
     } 
     d tt.%Save()
     s CountCol=..Send("run:   w rset.%Metadata.columns.Count()   ")
     s isSaveClass=0 
   ;  
   ;  d NewProperty(tt,"isDestroy","%Library.Integer","Признак удаления записи")   
   ;  d NewProperty(tt,"LastObj",DstClassName,"Последняя версия модификации записи")   
   ;  d NewProperty(tt,"FirstObj",DstClassName,"Первая версия модификации записи")   
   ;  d NewProperty(tt,"ParentObj",DstClassName,"Предыдущая версия модификации записи")   
   ;  d NewProperty(tt,"ChaildObj",DstClassName,"Последующая версия модификации записи" )   
   ;  d NewProperty(tt,"DateCreate","%Library.Date","Дата создания записи" , "$p($h,"","",1)")   
   ;  d NewProperty(tt,"TimeCreate","%Library.Time","Время создания записи", "$p($h,"","",2)")   
   ;  d NewProperty(tt,"DateDestriy","%Library.Date","Дата удаления записи" , "$p($h,"","",1)")   
   ;  d NewProperty(tt,"TimeDestriy","%Library.Time","Время удаления записи", "$p($h,"","",2)")   
     for columnNumber=1:1:CountCol
     { 
          d ..Send("run:  s column=rset.%Metadata.columns.GetAt("_columnNumber_") ")
          s colName=..Send("run:  w column.colName  ")
          continue:colName="ID"
          ;  continue:colName="isDestroy"
          ;  continue:colName="LastObj"
          ;  continue:colName="FirstObj"
          ;  continue:colName="ParentObj"
          ;  continue:colName="ChaildObj"
          ;  continue:colName="DateCreate"
          ;  continue:colName="TimeCreate"
          ;  continue:colName="DateDestriy"
          ;  continue:colName="TimeDestriy"
          s isAddProperty=1
          for i=1:1:tt.Properties.Count() {
             if tt.Properties.GetAt(i).Name=colName  s isAddProperty=0  q
          }
          continue:isAddProperty=0
          s isSaveClass=1  
          s typeClass=..Send("run:  w column.typeClass.Name")
          s Descript=..Send("run:   w column.typeClass.Description")
          ; ^oddDEF("%Activate.Enum","4")
          s CompileNamespace=..Send("run:  w column.typeClass.CompileNamespace")
          ;    if $zObjClassMethod("%CompiledClass","%ExistsId",typeClass)=1{
          ;       s Propert.Type=typeClass
          ;    }
          ;  else{
          ;     s Propert.Type="%ZEN.proxyObject"
          ;  }
          s Description=""
          s Description=Description_$c(13,10)_CompileNamespace
          s Description=Description_$c(13,10)_typeClass
          s LocDescript=""
          if $d(^oddDEF(typeClass)),$d(^oddDEF(typeClass,"4")) s LocDescript=^oddDEF(typeClass,"4")
          if LocDescript'=Descript    s Description=Description_$c(13,10)_Descript
          
          if $zObjClassMethod("%CompiledClass","%ExistsId",typeClass)=0 s typeClass=""
          s property=..Send("run:   s tmp=column.property  zw tmp")
          ; w property,!,!
          s MAXLEN=+$p( $p(property, "|i%Parameters(""MAXLEN"") = ",2),$c(10),1)
          s:MAXLEN=50 MAXLEN=1024
          s InitialExpression=..Send("run:   w column.property.InitialExpression ")
          d NewProperty(tt,colName,typeClass,Description,InitialExpression,MAXLEN)   
          d tt.%Save()
     }
     if isSaveClass=1 {
         s tt.Description=tt.Description_$zd($p($h,",",1))_" "_$zt($p($h,",",2))_$c(13,10)
         s Host=..Send("run:   w $zu(110) ")
         s tt.Description=tt.Description_"Host:"_Host_$c(13,10)
         s tt.Description=tt.Description_"NameSpace:"_..NameSpace_$c(13,10)
         s tt.Description=tt.Description_"%ZMSrv.Controller:CreateTabFromSQL "_$c(13,10)_"SQL: "_SQLstr_$c(13,10)
         s tt.ProcedureBlock=1
         d tt.%Save()
         Do $system.OBJ.Compile(DstClassName,"cuk /checkuptodate=expandedonly")
     }
     d ..Send("run:  k rset ")
     q 1
     
NewProperty(ClassObj,Name,Type,Descript,DefoultValue="",MAXLEN=0)     
      s Propert=##class(%Dictionary.PropertyDefinition).%New()
      s Propert.Name=Name
      s Propert.Type=Type
      d Propert.%Save()
      s Propert.Description=Descript
      s:DefoultValue'="" Propert.InitialExpression=DefoultValue
      if MAXLEN>0 {
          d Propert.Parameters.SetAt(MAXLEN,"MAXLEN")
      }
      d ClassObj.Properties.Insert(Propert)
      q
NewIndex(ClassObj,name,ColName)
   q
}

/// Метод добавления объекта %ZEN.proxyObject в таблицу
/// <br> RecObject - Объект, который помещаем в хронилище 
/// <br> DstClassName - имя таблицы , куда помещвем объект
/// <br> %ListExistProperty... - список полей исключений, по которым определяется  создавать новый объект или изменять старый
Method AddObjectToTab(RecObject As %ZEN.proxyObject = "", DstClassName = "", %ListExistProperty...) As %Integer
{
	 s ..Error=""
     if RecObject=""  s ..Error="Объект не может быть пустым"   q 0
     if DstClassName=""  s ..Error="Имя таблицы не может быть пустым"   q 0
     ;  Проверяем список полей , токоторым будет производится определение уникальности записи
     if $Get(%ListBuldExistProperty)>0 {
          s SqlStr=" "
          s SqlStr=SqlStr_" select id as vid "
          s SqlStr=SqlStr_" from "_DstClassName_" where 1=1 "
          s strTmp=""
          for tPtr = 1:1:$Get(%ListBuldExistProperty) {
	        if '$d(RecObject.%data(%ListBuldExistProperty(tPtr))) {
		     ; s ..Error="Error: Поле """_%ListBuldExistProperty(tPtr)_""" Отсутствует в объекте "    
		     ; q 
	        }else{  
              s strTmp=strTmp_" and "_%ListBuldExistProperty(tPtr)_"='"_RecObject.%data(%ListBuldExistProperty(tPtr))_"' "
	        }
          }
          if strTmp'="" {
             s SqlStr=SqlStr_strTmp
             SET sqlExistRec = ##class(%SQL.Statement).%New() 
             SET qStatus = sqlExistRec.%Prepare(SqlStr)
             if qStatus'=1 s ..Error=##class(%Status).LogicalToOdbc(qStatus)  q 0
             SET RecExistRec = sqlExistRec.%Execute()
             if RecExistRec.%Next()=1 {
               s oZak1=$zObjClassMethod(DstClassName,"%OpenId",RecExistRec.%GetData(1))
             }else{
	           s oZak1=$zObjClassMethod(DstClassName,"%New")  
             }
          }else{
	         s oZak1=$zObjClassMethod(DstClassName,"%New")     
          }
     }else{
	    s oZak1=$zObjClassMethod(DstClassName,"%New")  
     }
    
     s key11=""
     for  {
         if $d(%MApplication) d %MApplication.ProcessMessages()
         if $d(MApplication) d MApplication.ProcessMessages()
         s key11=$o(RecObject.%data(key11))
         q:key11=""
         continue:key11="ID" ;  пропускаем поле с именем "ID" так как в результрующеё таблице тоже присутствует это поле
         try {  
            if $isobject($zObjProperty(oZak1,key11))=1 {
	           ; Дописать обработку объектов 
	           s $zObjProperty(oZak1,key11)=RecObject.%data(key11)    
            }else{
               s $zObjProperty(oZak1,key11)=RecObject.%data(key11)  
            }
         }CATCH ErrorHandle{  }
      }
      s err=oZak1.%Save()
      if err'=1   s ..Error=##class(%Status).LogicalToOdbc(err)  q 0
      q oZak1.%Id()
}

/// Метод выполняет терминальную команду Cache`. По окончанию выполнения результат врзвращается в тексте
///  w ##class(%ZMSrv.Controller).CacheExec("w $h ")
ClassMethod CacheExec(cmdCacheExec = "") As %String
{
   q:cmdCacheExec="" ""   
   s cmdCacheExecres=""
 ;   try {
      k ^SPOOL($job)  
      O 2:($job)
      U 2:($job)
      x cmdCacheExec    
      c 2:($job) 
      u 0
        s cmdCacheExecindexSPOOL=""
        f  s cmdCacheExecindexSPOOL=$o(^SPOOL($job,cmdCacheExecindexSPOOL)) q:cmdCacheExecindexSPOOL=""   d
        . s cmdCacheExecindexSPOOL2=cmdCacheExecindexSPOOL s cmdCacheExecindexSPOOL2=$o(^SPOOL($job,cmdCacheExecindexSPOOL2))
        . if cmdCacheExecindexSPOOL2'=""  d
        . . s cmdCacheExecres=cmdCacheExecres_^SPOOL($job,cmdCacheExecindexSPOOL)
        k ^SPOOL($job)       
 ;  }CATCH ErrorHandle{ 
 ;    s cmdCacheExecres=ErrorHandle
 ;  }
   k cmdCacheExec,cmdCacheExecindexSPOOL2,cmdCacheExecindexSPOOL
   q cmdCacheExecres
}

/// Копировать файлы между серверами
///  (!!!Работает с ошибкой При передачи бинарных файлов - писался для текстовых файлов!!!!)
///  d ##class(%ZMSrv.Controller).CopyFile("ne1232","D:\backup\log.txt","ne1232","D:\backup\Copylog.txt")
///  d ##class(%ZMSrv.Controller).CopyFile("ne1232","d:\backup\Penguins.jpg","ne1232","d:\backup\Penguins2.jpg")
ClassMethod CopyFile(SrcSrv = {$ZU(5)}, SrcDir, DstSrv = {$ZU(5)}, DstDir)
{
	  s objSrc=##class(%ZMSrv.Controller).%New()
	  s objSrc.Host=SrcSrv
	  s objSrc.Port=6006
	  s objSrc.UserName="_SYSTEM"
	  s objSrc.UserPass="SYS"
	  if objSrc.Connect()=1 {
         s objDst=##class(%ZMSrv.Controller).%New()
	     s objDst.Host=DstSrv
	     s objDst.Port=6006
	     s objDst.UserName="_SYSTEM"
	     s objDst.UserPass="SYS"
         if objDst.Connect()=1 {
             w !,objSrc.Send("ip")     
             w !,objSrc.Send("run: w $ZU(110)")       
             w !,objSrc.Send("run: w $job")
             d objSrc.Send("run: s file=##class(%FileCharacterStream).%New()")
             d objSrc.Send("run: s file.Filename="""_SrcDir_""" ")  
             d objDst.Send("run:  Set fileDst=##class(%File).%New("""_DstDir_""")")
             d objDst.Send("run:  Do fileDst.Open(""WSN"") ")  
             for   {
	             q:objSrc.Send("run: w file.AtEnd ")
                ;  s frag=objSrc.Send("run: w $ASCII(file.Read(1))  ") 
   	            ;  d objDst.Send("run:  w fileDst.Write($C("_frag_"))   ")  
                s frag=objSrc.Send("run: w $system.Encryption.Base64Encode(file.Read(50))  ")
                d objDst.Send("run:  w fileDst.Write($system.Encryption.Base64Decode("""_frag_"""))   ")  
                ; s frag=$system.Encryption.Base64Decode(objSrc.Send("run: w $system.Encryption.Base64Encode(file.Read(50))  ") )
                ; d objDst.Send("run:  w fileDst.Write($system.Encryption.Base64Decode("""_$system.Encryption.Base64Encode(frag)_"""))   ")  
             }
             d objSrc.Send("cls")  
             d objDst.Send("run:  s fileDst="""" ")  
         }else{
	        w !,"Error: "_objDst.Error,!
	     }
         d objDst.DisConnect()
	  }else{
	     w !,"Error: "_objSrc.Error,!
	  }
	  d objSrc.DisConnect()
	  q
}

}

