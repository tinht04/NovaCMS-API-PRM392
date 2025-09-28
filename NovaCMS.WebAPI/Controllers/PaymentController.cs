using Microsoft.AspNetCore.Mvc;
using NovaCMS.Application.DTOs.VnPay;
using NovaCMS.Application.Interfaces.IServices;
using NovaCMS.Application.Utils;
using System.Globalization;
using System.Net;

namespace NovaCMS.API.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class PaymentController : ControllerBase
	{
		private readonly IVnPayService _vnPayService;
		
		public PaymentController(IVnPayService vnPayService)
		{
			_vnPayService = vnPayService;
		}

		[HttpPost]
		public IActionResult CreatePaymentUrl(PaymentInformationModel model)
		{
			if (model == null)
			{
				return BadRequest("Invalid payment information.");
			}

			try
			{
				var url = _vnPayService.CreatePaymentUrl(model, HttpContext);
				return Ok(new { paymentUrl = url });
			}
			catch (Exception ex)
			{
				return StatusCode(500, $"An error occurred: {ex.Message}");
			}
		}

		[HttpGet("callback")]
		public IActionResult PaymentCallback()
		{
			try
			{
				var response = _vnPayService.PaymentExecute(Request.Query);
				return Redirect($"http://localhost:5173/payment/{response.Success}");
			}
			catch (Exception ex)
			{
				return StatusCode(500, "An error occurred during payment callback.");
			}
		}
	}
}