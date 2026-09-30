<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
<head>

    <meta charset="UTF-8">

    <title>Login - Scheduling and Dispatching System</title>

</head>

<body>

    <h1>Scheduling and Dispatching System</h1>

    <h2>Login</h2>

    <% String error = (String) request.getAttribute("error"); %>

    <% if (error != null) { %>

        <p style="color:red;">
            <%= error %>
        </p>

    <% } %>

    <form method="post"
          action="<%= request.getContextPath() %>/login">

        <div>

            <label for="username">
                Username:
            </label>

            <input type="text"
                   id="username"
                   name="username"
                   required>

        </div>

        <br>

        <div>

            <label for="password">
                Password:
            </label>

            <input type="password"
                   id="password"
                   name="password"
                   required>

        </div>

        <br>

        <button type="submit">
            Login
        </button>

    </form>

</body>
</html>