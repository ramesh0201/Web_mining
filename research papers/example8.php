<?php
error_reporting(0);

function return_all_urls($url,$url_domain)
{
   $url_host=parse_url($url, PHP_URL_HOST);
   echo $url_host;
   echo "<br/>";
   $chwnd = curl_init();
   curl_setopt($chwnd, CURLOPT_URL,$url);
   curl_setopt($chwnd, CURLOPT_VERBOSE, 1);
   curl_setopt($chwnd, CURLOPT_POST, 0);
   curl_setopt($chwnd, CURLOPT_RETURNTRANSFER,1);
   $result = curl_exec($chwnd);
   curl_close ($chwnd);
   
    echo "<br/>";
    var_dump($result);
    echo "<br/>";
    echo "<br/>";
    
   if( $result )
     {
       echo "<br/>";
       var_dump($result);

       //collect all the links
        preg_match_all( '/<a(?:[^>]*)href=\"([^\"]*)\"(?:[^>]*)>(?:[^<]*)<\/a>/is', $result, $output, PREG_SET_ORDER );
       preg_match_all('/[\w\-]+\.(jpg)/', $result, $output, PREG_SET_ORDER );
       
       preg_match_all( '/<a(?:[^>]*)href=\"([^\"]*)\"(?:[^>]*)>(?:[^<]*)<\/a>/is', $result, $output, PREG_SET_ORDER );
       
       
	var_dump($output);
       
   }

   //return $url_array;
} //function

function url_exist($url){//se passar a URL existe
    $c=curl_init();
    curl_setopt($c,CURLOPT_URL,$url);
    curl_setopt($c,CURLOPT_HEADER,1);//get the header
    curl_setopt($c,CURLOPT_NOBODY,1);//and *only* get the header
    curl_setopt($c,CURLOPT_RETURNTRANSFER,1);//get the response as a string from curl_exec(), rather than echoing it
    curl_setopt($c,CURLOPT_FRESH_CONNECT,1);//don't use a cached version of the url
    if(!curl_exec($c)){
      //echo $url.' inexists';
        return 0;
    }else{
      //echo $url.' exists';
        return 1;
    }
    //$httpcode=curl_getinfo($c,CURLINFO_HTTP_CODE);
    //return ($httpcode<400);
}

function saveContent_with_ext($url,$name,$ext)
{
  //$contents= file_get_contents("http://scottsdale.hyatt.com/hyatt/images/hotels/scott/floorplan.pdf");
$contents= file_get_contents($url);
$full_name=$name.$ext;
echo $full_name;
$savefile = fopen($full_name, 'w');
fwrite($savefile, $contents);
fclose($savefile);
}

function saveContent_wo_ext($url,$name)
{
  //$contents= file_get_contents("http://scottsdale.hyatt.com/hyatt/images/hotels/scott/floorplan.pdf");
$contents= file_get_contents($url);
$full_name=$name;
echo $full_name;
$savefile = fopen($full_name, 'w');
$success = fwrite($savefile, $contents);
echo $success;
echo "<br/>";
fclose($savefile);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // EXTRACT LINKS FROM MAIN URL
//$main_url = $url; //"http://www.law.asu.edu/library/";
$url = "http://www.public.asu.edu/~bli24/";
//echo $main_url;
//echo "<br/>";
//echo $url;
//echo "<br/>";
// OBTAIN THE DOMAIN
       $url_domain=parse_url($url, PHP_URL_HOST);
       echo "domain found !!";
       echo "<br/>";
       echo "DOMAIN :";
       echo $url_domain;
       echo "<br/>";

return_all_urls($url,$url_domain);

/*
$first_layer_urls = array_unique($first_layer);


foreach( $first_layer_urls as $item )
      {
	$temp = search_keywords($item);
	var_dump($temp);
	echo "<br/>";
}
*/

///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

    // look for papers or publications


    // look for research interests 


    // look for 



?>