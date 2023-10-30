using Microsoft.AspNetCore.Mvc;
using Hemtentamen_Databaskonstruktion.Models;
using Hemtentamen_Databaskonstruktion.Views.Home;

namespace Hemtentamen_Databaskonstruktion.Controllers
{
    public class HusController : Controller
    {
        private readonly YourDbContext _context; // Replace YourDbContext with your actual database context

        // Constructor for injecting the database context
        public HusController(YourDbContext context)
        {
            _context = context;
        }

        // Other action methods could be here

        private List<Hus> husList = new List<Hus>();


        [HttpPost]
        public IActionResult AdderaHus(HusViewModel husViewModel)
        {
            if (ModelState.IsValid)
            {
                // Map the data from the ViewModel to the Hus model
                Hus hus = new Hus
                {
                    Adress = husViewModel.Adress,
                    Plats = husViewModel.Plats,
                    Kategori = husViewModel.Kategori,
                    Längd = husViewModel.Längd,
                    Bredd = husViewModel.Bredd,
                    MaterialId = husViewModel.MaterialId,
                    Kostnad = husViewModel.Kostnad
                };

                // Add the Hus object to the database and save the changes
                _context.Hus.Add(hus);
                _context.SaveChanges();

                // Redirect to a success page or perform any other necessary action
                return RedirectToAction("Success");
            }

            // If the model state is not valid, return the form with validation errors
            return View("YourViewName", husViewModel); // Replace YourViewName with the actual view name
        }
    }
}