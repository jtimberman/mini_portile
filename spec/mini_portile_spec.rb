require "spec_helper"
require "mini_portile"

describe MiniPortile do
  let(:logger) { Support::BlackHole.new }
  let(:recipe) { MiniPortile.new("amhello", "1.0") }
  let(:url) { fixture_file("amhello-1.0.tar.gz") }
  in_temporary_directory

  before :each do
    recipe.logger = logger
    recipe.files << url
  end

  describe "#download" do
    it "downloads the indicated file" do
      recipe.download
      FakeWeb.should have_requested(:get, url)
    end

    it "places the downladed file in archives directory" do
      recipe.download
      archives = Dir.glob("ports/archives/*.*")
      archives.should include("ports/archives/amhello-1.0.tar.gz")
    end
  end

  describe "#downloaded?" do
    it "changes after all files have been downloaded" do
      expect {
        recipe.download
      }.should change { recipe.downloaded? }
    end
  end

  describe "#extract" do
    before :each do
      recipe.download
    end

    it "extracts files into a temporary location" do
      recipe.extract
      artifacts = Dir.glob("tmp/**/ports/amhello/1.0/*")
      artifacts.should_not be_empty
    end
  end

  describe "#configure" do
    before :each do
      recipe.download
      recipe.extract
    end

    it "succeed in the configure process" do
      recipe.configure.should be_true
    end

    it "generates a log from configure output" do
      recipe.configure
      logs = Dir.glob("tmp/**/ports/amhello/1.0/configure.log")
      logs.should_not be_empty
    end

    it "checks for previous configured state" do
      recipe.should_receive(:configured?).and_return(true)
      recipe.configure
    end
  end

  describe "#configured?" do
    before :each do
      recipe.download
      recipe.extract
    end

    it "changes after configure process succeed" do
      expect {
        recipe.configure
      }.should change { recipe.configured? }
    end
  end

  describe "#compile" do
    before :each do
      recipe.download
      recipe.extract
      recipe.configure
    end

    it "succeed in the compile process" do
      recipe.compile.should be_true
    end

    it "generates a log from compile output" do
      recipe.compile
      logs = Dir.glob("tmp/**/ports/amhello/1.0/compile.log")
      logs.should_not be_empty
    end
  end

  describe "#install" do
    before :each do
      recipe.download
      recipe.extract
      recipe.configure
      recipe.compile
    end

    it "succeed in the install process" do
      recipe.install.should be_true
    end

    it "generates a log from install output" do
      recipe.install
      logs = Dir.glob("tmp/**/ports/amhello/1.0/install.log")
      logs.should_not be_empty
    end

    it "places the installation in ports directory" do
      recipe.install
      artifacts = Dir.glob("ports/**/amhello/1.0/bin/*")
      artifacts.should_not be_empty
    end

    it "checks for previous installed state" do
      recipe.should_receive(:installed?).and_return(true)
      recipe.install
    end
  end

  describe "#installed?" do
    before :each do
      recipe.download
      recipe.extract
      recipe.configure
      recipe.compile
    end

    it "changes after install process succeeded" do
      expect {
        recipe.install
      }.should change { recipe.installed? }
    end
  end
end
