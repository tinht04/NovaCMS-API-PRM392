using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace NovaCMS.Application.Utils
{
	public class Utils
	{
		public static String HmacSHA512(string key, String inputData)
		{
			var hash = new StringBuilder();
			byte[] keyBytes = Encoding.UTF8.GetBytes(key);
			byte[] inputBytes = Encoding.UTF8.GetBytes(inputData);
			using (var hmac = new HMACSHA512(keyBytes))
			{
				byte[] hashValue = hmac.ComputeHash(inputBytes);
				foreach (var theByte in hashValue)
				{
					hash.Append(theByte.ToString("x2"));
				}
			}

			return hash.ToString();
		}
		public string GetIpAddress(HttpContext context)
		{
			var ipAddress = string.Empty;
			try
			{
				var remoteIpAddress = context.Connection.RemoteIpAddress;

				if (remoteIpAddress != null)
				{
					if (remoteIpAddress.AddressFamily == AddressFamily.InterNetworkV6)
					{
						remoteIpAddress = Dns.GetHostEntry(remoteIpAddress).AddressList
							.FirstOrDefault(x => x.AddressFamily == AddressFamily.InterNetwork);
					}

					if (remoteIpAddress != null) ipAddress = remoteIpAddress.ToString();

					return ipAddress;
				}
			}
			catch (Exception ex)
			{
				return ex.Message;
			}

			return "127.0.0.1";
		}

	}
}
