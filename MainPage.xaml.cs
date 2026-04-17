using System.Numerics;
using System.Threading;
using Environmentor.ViewModel;

namespace Environmentor;

public partial class MainPage : ContentPage
{
	//string TextData;
	//FileResult result;

	public MainPage(MainViewModel vm)
	{
		InitializeComponent();
		BindingContext = vm;
	}
}