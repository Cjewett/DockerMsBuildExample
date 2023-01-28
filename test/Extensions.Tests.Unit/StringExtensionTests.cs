using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Extensions.Tests.Unit
{
    [TestClass]
    public class StringExtensionTests
    {
        [TestMethod]
        public void Randomize_Test()
        {
            Assert.IsTrue(true, "true".Randomize());
        }
    }
}
