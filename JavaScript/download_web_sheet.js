var csv_data = [];

// --------------------> 获得网页中表格的数据 <--------------------
// Get each row data
var rows = document.getElementsByTagName('tr');
for (var i = 0; i < rows.length; i++) {
  // Get each column data
  var cols = rows[i].querySelectorAll('td,th');
  // Stores each csv row data
  var csvrow = [];
  for (var j = 0; j < cols.length-1; j++) {
    // Get the text data of each cell of
    // a row and push it to csvrow
    //csvrow.push(cols[j].innerHTML);
    var isLink = cols[j].querySelector('a');
    var isSpan = cols[j].querySelector('span');
    if (isLink != null) 
      csvrow.push(isLink.innerHTML);
    else if (isSpan != null) 
      csvrow.push(isSpan.innerHTML.replace("\n",""));
    else 
      csvrow.push(cols[j].innerHTML);
  }
  // Combine each column value with comma
  csv_data.push(csvrow.join(","));
}
// combine each row data with new line character
csv_data = csv_data.join('\n');
    
    
    
// --------------------> 将csv文件下载到本地 <--------------------
// Create CSV file object and feed our
// csv_data into it
CSVFile = new Blob([csv_data], { type: "text/csv" });
// Create to temporary link to initiate
// download process
var temp_link = document.createElement('a');
// Download csv file
temp_link.download = "GfG.csv";
var url = window.URL.createObjectURL(CSVFile);
temp_link.href = url;
 
// This link should not be displayed
temp_link.style.display = "none";
document.body.appendChild(temp_link);
 
// Automatically click the link to trigger download
temp_link.click();
document.body.removeChild(temp_link);