require 'formula'

class Hyperestraier < Formula
  class << self
    def mecab_support?
      ARGV.include? '--enable-mecab'
    end
  end

  url 'http://fallabs.com/hyperestraier/hyperestraier-1.4.13.tar.gz'
  homepage 'http://fallabs.com/hyperestraier/index.html'
  md5 '133305e54785a93b25f4e2f7b421e80d'

  depends_on 'qdbm'
  if mecab_support?
    depends_on 'mecab'
    depends_on 'mecab-ipadic'
  end

  def options
    [['--enable-mecab', 'Include MeCab support']]
  end

  def install
    args = [
      "--disable-debug",
      "--disable-dependency-tracking",
      "--prefix=#{prefix}"
    ]

    if self.class.mecab_support?
      unless mecab_dic_charset == 'euc'
        onoe ask_for_mecab_ipadic_reinstallation
        exit 1
      end
      args << '--enable-mecab'
    else
      ohai 'hyperestraier will be built without MeCab support. To build it with MeCab support, use --enable-mecab option.'
    end

    system "./configure", *args
    system "make mac"
    system "make check-mac"
    system "make install-mac"
  end

  def test
    system "estcmd version"
  end

  private

  def mecab_dic_charset
    /^charset:\t(\S+)$/ =~ `mecab -D` && $1
  end

  def ask_for_mecab_ipadic_reinstallation
    <<-EOS.undent
        Hyper Estraier supports only the EUC-JP version of MeCab-IPADIC. However, you have installed the #{mecab_dic_charset} version so far.

        You have to reinstall your mecab-ipadic package manually with the
        --with-charset=euc option before resuming the hyperestraier installation,
        or you have to build hyperestraier without MeCab support.

        To reinstall your mecab-ipadic and resume the hyperestraier installation:

            $ brew uninstall mecab-ipadic
            $ brew install mecab-ipadic --with-charset=euc
            $ brew install hyperestraier

        To build hyperestraier without MeCab support:

            $ brew install hyperestraier
    EOS
  end
end
