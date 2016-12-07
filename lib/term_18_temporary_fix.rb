# The term 18 page has an off by one error in the rowspans. This means that
# we're picking up a party name instead of a person name. I've fixed this on
# Wikipedia, but my revision is waiting for approval.
#
# Once the revision linked to below has been approved this class and can be
# deleted.
#
# https://tr.wikipedia.org/w/index.php?title=TBMM_18._d%C3%B6nem_milletvekilleri_listesi&type=revision&diff=17880266&oldid=16742759
class Term18TemporaryFix < Scraped::Response::Decorator
  OLD = '<td rowspan="26"><b><a href="/wiki/Ankara_milletvekilleri" title="Ankara milletvekilleri">Ankara</a></b></td>'
  NEW = '<td rowspan="27"><b><a href="/wiki/Ankara_milletvekilleri" title="Ankara milletvekilleri">Ankara</a></b></td>'

  def body
    super.sub(OLD, NEW)
  end
end
