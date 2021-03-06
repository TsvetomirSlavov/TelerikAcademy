<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">  
        <title><?=$data['title'] ?></title>
        <link href="styles/bootstrap.css" rel="stylesheet" />
    </head>
    <body>
        <div class="navbar">
            <div class="navbar-inner">
                <a class="brand" href="index.php">Book system</a>
                <ul class="nav">
                    <li><a href="index.php">All books</a></li>
                    <li><a href="addBook.php">Add new book</a></li>
                    <li><a href="addAuthor.php">Add new author</a></li>
                    <li><a href="logout.php">Logout</a></li>
                </ul>
            </div>
        </div>
        <div class="container-fluid">
            <?php
            include $data['content'];
            ?>
        </div>
    </body>
</html>
