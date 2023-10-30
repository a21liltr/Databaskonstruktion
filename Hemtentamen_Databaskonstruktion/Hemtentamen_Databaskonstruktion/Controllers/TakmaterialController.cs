using Microsoft.AspNetCore.Mvc;

namespace Hemtentamen_Databaskonstruktion.Controllers
{
    public class TakmaterialController : Controller
    {
        private readonly string _connectionString = "Your_Connection_String"; // Replace with your actual connection string

        public IActionResult Search(string searchString)
        {
            List<Takmaterial> searchResult = new List<Takmaterial>();

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                SqlCommand command = connection.CreateCommand();
                command.CommandText = "SELECT * FROM Takmaterial WHERE Namn LIKE @SearchString OR Tillverkare LIKE @SearchString";
                command.Parameters.AddWithValue("@SearchString", "%" + searchString + "%");

                SqlDataReader reader = command.ExecuteReader();

                while (reader.Read())
                {
                    Takmaterial takmaterial = new Takmaterial
                    {
                        // Assuming the structure of the Takmaterial class
                        Namn = reader["Namn"].ToString(),
                        Tillverkare = reader["Tillverkare"].ToString(),
                        // Add other properties here as needed
                    };
                    searchResult.Add(takmaterial);
                }
            }

            // Pass the search result to the view or perform any other necessary operation
            return View("SearchResult", searchResult); // Replace "SearchResult" with the name of your search result view
        }
    }
}