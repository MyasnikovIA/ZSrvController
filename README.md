<br># ZSrvController  (Cache` Intersystems)
<br><h2>%ZMSrv.Controller</h2>
<br>
<br>Организации обмена между серверами Cache' (Удаленное подключение к серверу).
<br>Проверить работу можно применив PuTTY.exe (https://putty.org.ru/download.html).
<br>
<br>
<br> <H3>  Обрабатываемые команды:</H3><br> <pre><h4><br>   "ip"         -  Получиь IP адрес клиента со стороны сервера<br>   "run: w $h"  -  Выполнить однострочную команду<br>   "cls"        -  Очистить буфер команд на стороне сервера<br>   "read"       -  Прочитать буфер команд записанные на стороне сервера<br>   "run"        -  Выполнить команды записанные в буфере на стороне сервера<br>   "runline"    -  Выполнить построчно команды записанные в буфере на стороне сервера<br>   "key"        -  Получить ключ сесии<br>   "exit"       -  Разорвать соединение<br>   "ping"       -  тестовый запрос (после него произойдёт разрыв соединения)<br>   "gl"         -  показать имя  глобала в котором хранится буфер<br>   "gl:^GBuff"  -  Установить имя  глобала в котором хранится буфер<br>   "setapp:AppName"- Указываем название приложение из которого подключились <br>   Все остальные строки записываются в буфер  на стороне сервера.<br>    </h4><br> </pre><br> <h4> Запуск сервера </h4> <br>  
<pre> ; 8200 - номер порта для соединения<br>  ;"USER" - область имен по умолчанию   <br>  do ##class(%ZMSrv.Controller).StartSRV(8200,"USER")
</pre><br>  <br> <h4> Остановить сервер </h4> <br>  
<pre>; 8200 - номер порта для соединения <br>   do ##class(%ZMSrv.Controller).StopSRV(8200) 
</pre><br> <br> <h4> Проверить запущен ли сервер</h4> <br>  
<pre>                                         ;    IP       ,Port<br>   if ##class(%ZMSrv.Controller).ExistSRV("10.100.12.21",8200)=1{<br>      W "Сервер доступен" <br>   } else {<br>      W "Сервер НЕ доступен " <br>   } 
</pre><br> <br><br><br><br>

<br> <h4>  Пример подключения к Серверу из Cache' </h4> <br> 
<pre>
          s obj=##class(%ZMSrv.Controller).%New()
	  if obj.Connect("127.0.0.1","SAMPLES",6010,"_SYSTEM","SYS")=1 { 
	     w !,obj.Send("run: w $h")
	     s ExternalObject=obj.GetObject("Cinema.Film","1" )
	     w !,!
	     zw ExternalObject
	  }else{
	     w !,"Error: "_obj.Error,!
	  }
	  d obj.DisConnect()
	  s obj=""
</pre>  

<br> <h4>  Пример подключения к Серверу из Cache' </h4> <br> 
<pre>
          s obj=##class(%ZMSrv.Controller).%New()
	  if obj.Connect("127.0.0.1",6006,"USER","_SYSTEM","SYS")=1 {
	     w !,obj.Send("ip")     
	     w !,obj.Send("run: w $ZU(110)")       
	     ; Наполняем буфер командами Cache'
	     d obj.Send(" for a=1:1:100 d ")       
	     d obj.Send(" .   w $JOB_"":""_a         ")      
	     d obj.Send(" .   w $c(13,10) ")     
	     w !,obj.Send("run") ; запустить выполнение команд в буфере
	     d obj.Send("cls")   ; Очистить буфер на стороне сервера 
	     w !,"SessionKey: "_obj.SessionKey
	  }else{
	     w !,"Error: "_obj.Error,!
	  }
	  d obj.DisConnect()
	  q
</pre>

<br> <h4>  Пример подключения к Серверу из Cache' </h4> <br> 
<pre><br>   s obj=##class(%ZMSrv.Controller).%New()<br>   s obj.Host="127.0.0.1"<br>   s obj.Port=8200<br>   s obj.UserName="_SYSTEM"<br>   s obj.UserPass="SYS"<br>   s obj.NameSpace="USER"<br>   if obj.Connect()=1 {<br>      w !,obj.Send("ip")     <br>      w !,obj.Send("run: w $ZU(110)")       <br>      ; Наполняем буфер командами Cache'<br>      d obj.Send(" for a=1:1:100 d ")       <br>      d obj.Send(" .   w $JOB_"":""_a         ")      <br>      d obj.Send(" .   w $c(13,10) ")     <br>      w !,obj.Send("run") ; запустить выполнение команд в буфере<br>      d obj.Send("cls")   ; Очистить буфер на стороне сервера <br>      w !,"SessionKey: "_obj.SessionKey<br>   }else{<br>      w !,"Error: "_obj.Error,!<br>   }<br>   d obj.DisConnect()<br>   q<br> 
</pre><br> <br>  <h4> Получение SQL запроса с удаленного сервера</h4> <br>  
<pre><br> <br>  ;  Класс в кодом находится запроса<br>  ;  Class Demo.Import5 {<br>  ;     ClassMethod test(SqlStr) {<br>  ;       s SQLobj=##class(%SQL.Statement).%New()<br>  ;       d SQLobj.%Prepare(SqlStr)<br>  ;       s DataSet=SQLobj.%Execute()<br>  ;       s QMeta=DataSet.%GetMetaData()<br>  ;     }<br>  ;  }<br>   s obj=##class(%ZMSrv.Controller).%New()<br>   s obj.Host="ne1234"<br>   s obj.Port=8200<br>   s obj.UserName="_SYSTEM"<br>   s obj.UserPass="SYS"<br>   s obj.NameSpace="USER"<br>   if obj.Connect()=0 {  w !,"Error: "_obj.Error,! q $$$OK   }<br>   ; Вызываем класс метод<br>   w obj.RunClassMethod("Demo.Import5","test","select top (500) * from Contracts.EPhDogovor where 1=1 ")  <br>   for  {<br>       q:+obj.Send("run: w DataSet.%Next()")=0<br>       w obj.Send("run: w QMeta.columns.GetAt(1).colName")_"="_obj.Send("run: w DataSet.%GetData(1)")<br>   }<br>   d obj.DisConnect()<br> <br> <br>  
</pre><br> <h4> Получение SQL запроса на удаленном сервере(вариант 2) </h4><br>  
<pre><br>            s SqlStr="select * from %SYS.ProcessQuery"<br>            s obj=##class(%ZMSrv.Controller).%New()<br>            ;   s obj.Host="127.0.0.1"<br>            ;   s obj.Port=8200<br>            ;   s obj.UserName="_SYSTEM"<br>            ;   s obj.UserPass="SYS"            <br>            s obj.NameSpace="SAMPLES"<br>            if obj.Connect()=1 {<br>                ;  s obj.TimeOut=0<br>                ;  s SqlStr="select top (?) * from Contracts.EPhDogovor where 1=1  and id [ ? "<br>                ;  d obj.SqlExec("",SqlStr,10,999)<br>                if obj.SqlExec("",SqlStr)'=1 {   <br>                   w obj.Error       <br>                }else{<br>                   for  {<br>                       s ResNext=obj.SqlNextRaw("")<br>                       q:ResNext=0<br>                       if ResNext="" {<br>                          w obj.Error<br>                          q    <br>                       }<br>                       s re=obj.SqlGetRaw("")<br>                       zw re ; показать объект<br>                    }<br>                }<br>            }   <br>            d obj.DisConnect()<br>            q<br> <br>  
</pre><br> <br>  <h4>Получить объекты из Query запроса</h4><br>  
<pre><br>               s obj=##class(%ZMSrv.Controller).%New()<br>               ;   s obj.Host="127.0.0.1"<br>               ;   s obj.Port=8200<br>               ;   s obj.UserName="_SYSTEM"<br>               ;   s obj.UserPass="SYS"<br>                 s obj.NameSpace="SAMPLES"<br>                 if obj.Connect()=1 {<br>                   if obj.SqlQuery("","%Dictionary.ClassDefinition:Summary" )'=1  q<br>                   for  {<br>                       s resNext=obj.SqlQueryNext("")<br>                       q:resNext=0<br>                       if resNext="" {<br>                          w "Error: "_obj.Error,!<br>                          q<br>                       }<br>                       s re=obj.SqlQueryGet("")<br>                       zw re<br>                   }<br>                      <br>                 }else{<br>                   w !,"Error: "_obj.Error,!<br>                 }<br>                 d obj.DisConnect()<br>                 q<br>  
</pre><br>  <h4> Получить объект по ID   </h4><br>  
<pre><br>       s obj=##class(%ZMSrv.Controller).%New()<br>       s obj.Host="127.0.0.1"<br>       s obj.Port=8200<br>       s obj.UserName="_SYSTEM"<br>       s obj.UserPass="SYS"<br>       s obj.NameSpace="SAMPLES"<br>       if obj.Connect()=1 {<br>         s ExternalObject=obj.GetObject("Cinema.Film","1" )  <br>         zw ExternalObject<br>       }else{<br>         w !,"Error: "_obj.Error,!<br>       }<br>       d obj.DisConnect()<br>  
</pre><br>  <h4>Создать локально таблицу по SQL запросу во внешнюю БД и заполнить её результатом запроса </h4><br>  
<pre><br>          ; select * from TabDst4<br>          ; --delete from TabDst4<br>           s obj=##class(%ZMSrv.Controller).%New()<br>           s obj.Host="127.0.0.1"<br>           s obj.Port=8200<br>           s obj.UserName="_SYSTEM"<br>           s obj.UserPass="SYS"<br>           s obj.NameSpace="SAMPLES"<br>           if obj.Connect()=1 {<br>               s SQLstr="select top 4 id as OldID , ID , Title, Description ,  TicketsSold from Cinema.Film"<br>               s DstClassName = "User.TabDst4"<br>               d obj.CreateTabFromSQL(SQLstr,DstClassName )     ; создаем таблицу<br>               d obj.SqlExec("test", SQLstr) ; Делаем запрос данных  <br>               s RawInd=0<br>               for  {<br>                  q:obj.SqlNextRaw("test")=0<br>                  #DIM RecObject as  %ZEN.proxyObject =obj.SqlGetRaw("test")<br>                  s RawInd=RawInd+1<br>                  ; Создание записи в таблице <br>                  s oZak1=$zObjClassMethod(DstClassName,"%New")<br>                  s key=""<br>                  for {<br>                     s key=$o(RecObject.%data(key))<br>                     q:key=""<br>                     continue:key11="ID"<br>                     s $zObjProperty(oZak1,key11)=RecObject.%data(key)<br>                     ; w RawInd_") ||"_RecObject.ID_"||"_key_"  "_RecObject.%data(key),!<br>                  }<br>                  s err=oZak1.%Save()<br>               }<br>           }else{<br>             w !,"Error: "_obj.Error,!<br>           }<br>           d obj.DisConnect()<br>           q<br>  <br>  
</pre><br>  <h4>Создаем таблицу из SQL запроса и заносим в неё данние </h4><br>  
<pre><br>           s obj=##class(%ZMSrv.Controller).%New()<br>           s obj.Host="127.0.0.1"<br>           s obj.Port=8200<br>           s obj.UserName="_SYSTEM"<br>           s obj.UserPass="SYS"<br>           s obj.NameSpace="SAMPLES"<br>           if obj.Connect()=1 {<br>               s SQLstr="select top 4 id as OldID , ID , Title, Description ,  TicketsSold from Cinema.Film"<br>               s DstClassName = "User.TabDst4"<br>               d obj.CreateTabFromSQL(SQLstr,DstClassName )     ; создаем таблицу<br>               d obj.SqlExec("test", SQLstr) ; Делаем запрос данных  <br>               s RawInd=0<br>               for  {<br>                  q:obj.SqlNextRaw("test")=0<br>                  s RawInd=RawInd+1<br>                  #DIM RecObject as  %ZEN.proxyObject =obj.SqlGetRaw("test")<br>                  s res=obj.AddObjectToTab(RecObject,DstClassName )  ; Добавляем объект в таблицу и получаем ID новой записи<br>                  if res=0  w obj.Error,!   ; если ID равен 0 , тогда произошла ошибка в процессе записи<br>                  e         w res,!<br>               }<br>           }else{<br>             w !,"Error: "_obj.Error,!<br>           }<br>           d obj.DisConnect()<br>           q<br> <br>  
</pre>
