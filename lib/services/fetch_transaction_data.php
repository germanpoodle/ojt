<?php
// Allow from any origin
if (isset($_SERVER['HTTP_ORIGIN'])) {
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Credentials: true");
    header("Access-Control-Max-Age: 86400");    // cache for 1 day
}

// Set the content type as JSON
header('Content-Type: application/json');

// Database credentials
$servername = "localhost";
$username = "root";
$password = "";
$database = "db_approval";
$port = '3306';

$conn = new mysqli($servername, $username, $password, $database, $port);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// SQL query to get specific columns from the table
$sql = "SELECT id, transacting_party, doc_no, DATE_FORMAT(date_trans, '%Y-%m-%d') as date_trans,
doc_type, check_no, check_drawee_bank, check_amount, transaction_status, remarks, online_processing_status FROM tbl_gl_cdb_list";
$result = $conn->query($sql);

// Initialize an empty array to store the final data
$data = [];

if ($result->num_rows > 0) {
    // Loop through the results and append to the $data array
    while($row = $result->fetch_assoc()) {
        // Convert check_amount to double
        $row['check_amount'] = (double) $row['check_amount'];

        // Append the modified row to $data
        $data[] = $row;
    }
} else {
    // No results found, return an empty array
    $data = [];
}

// Close the database connection
$conn->close();

// Output the JSON data
echo json_encode($data);
?>
