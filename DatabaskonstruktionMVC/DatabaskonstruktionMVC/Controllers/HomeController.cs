﻿using DatabaskonstruktionMVC.Models;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace DatabaskonstruktionMVC.Controllers
{
	public class HomeController : Controller
	{
		private readonly ILogger<HomeController> _logger;

		public HomeController(ILogger<HomeController> logger)
		{
			_logger = logger;
		}

		public IActionResult Index(string message)
		{
			ViewBag.Message = "Test message";

			var test = new Tester();
			test.Age = 1;
			test.Status = 0;
			test.Name = "Test";

			return View(test);
		}

		public IActionResult LoggedIn(string username, string password)
		{
			if (username != "agent" || password != "foo")
			{
				ViewBag.Message = "Wrong username or password";
				return RedirectToAction("Index", "Home");
			}
			else
			{
				return View();
			}
		}

		public IActionResult RegisterEntity(string EntitySelection)
		{
			ViewBag.Entity = EntitySelection;
			return View();
		}

		public IActionResult Privacy()
		{
			return View();
		}

		[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
		public IActionResult Error()
		{
			return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
		}
	}
}