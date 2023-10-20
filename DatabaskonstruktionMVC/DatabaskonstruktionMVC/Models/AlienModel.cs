using MySql.Data.MySqlClient;
using System.Data;

namespace DatabaskonstruktionMVC.Models
{
    public class AlienModel
    {
        private IConfiguration _configuration;
        private string connectionString;
        public AlienModel(IConfiguration configuration)
        {
            _configuration = configuration;
            connectionString = _configuration["ConnectionString"];
        }

        public DataTable GetAliens()
        {
            MySqlConnection connection = new MySqlConnection(connectionString);
            connection.Open();
            MySqlDataAdapter adapter = new MySqlDataAdapter("SELECT * FROM Alien;", connection);
            DataSet ds = new DataSet();
            adapter.Fill(ds, "result");
            DataTable alienTable = ds.Tables["result"];
            connection.Close();

            return alienTable;
        }
    }
}
