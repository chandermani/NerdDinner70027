using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;

namespace NerdDinner.Helpers
{
    public class DatabaseCreator
    {
        public void CreateNerdDinnerDBSchema()
        {
            //create connection
            string connString = ConfigurationManager.ConnectionStrings["NerdDinners"].ConnectionString;
            SqlConnection c = new SqlConnection(connString);

            //load generated SQL script into a string
            FileInfo file = new FileInfo(HttpContext.Current.Server.MapPath("Nerddinner.sql"));
            string tableScript = file.OpenText().ReadToEnd();

            c.Open();
            //execute sql script and create tables
            SqlCommand command = new SqlCommand(tableScript, c);
            command.ExecuteNonQuery();
            file.OpenText().Close();
            c.Close();

            command.Dispose();
            c.Dispose();

        }

        public void CreateASPNETDBSchema()
        {
            //create connection
            string connString = ConfigurationManager.ConnectionStrings["ApplicationServices"].ConnectionString;
            SqlConnection c = new SqlConnection(connString);

            //load generated SQL script into a string
            FileInfo file = new FileInfo(HttpContext.Current.Server.MapPath("aspnetdb.sql"));
            string tableScript = file.OpenText().ReadToEnd();

            c.Open();
            //execute sql script and create tables
            SqlCommand command = new SqlCommand(tableScript, c);
            command.ExecuteNonQuery();
            file.OpenText().Close();
            c.Close();

            command.Dispose();
            c.Dispose();
        }
    }
}