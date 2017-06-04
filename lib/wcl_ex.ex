defmodule WclEx do

  defmodule Loan do
    defstruct [author: "", 
      title: "", 
      due: "", 
      pub: "", 
      call: "",
      status: "",
      number: "",
      on: "",
      at: "",
      isbn: ""]
  end
  require Logger

  def loans(pid, surname) do
    use Hound.Helpers
    Hound.start_session

    navigate_to "http://www.wcl.govt.nz/carlweb/jsp/piplogin.jsp"
    pid_element = find_element(:name, "pid")
    surname_element = find_element(:name, "name")
    fill_field(pid_element, pid)
    fill_field(surname_element, surname)
    submit_element(pid_element)
    
    navigate_to "http://www.wcl.govt.nz/carlweb/jsp/pipsummary.jsp"
    find_element(:link_text, "Loans") |> click()
    
    navigate_to "http://www.wcl.govt.nz/carlweb/jsp/pipcharges.jsp"
    find_element(:name, "expand") |> click()
    
    authors = find_all_elements(:class, "pip_author") 
      |> Enum.filter(fn(x) -> css_property(x, "display") == "none" end) 
      |> Enum.map(&inner_text/1)

     titles = find_all_elements(:class, "pip_title")
      |> Enum.drop(1) 
      |> Enum.map(&inner_text/1) 
      |> Enum.map(&String.replace(&1, "/", "")) 
      |> Enum.map(&String.trim/1)

    dues  = find_all_elements(:class, "pip_dueDate") 
      |> Enum.drop(1) 
      |> Enum.take_every(2) 
      |> Enum.map(&inner_text/1)

    pubs = find_all_elements(:class, "pip_pubDate")
      |> Enum.drop(1) 
      |> Enum.take_every(2) 
      |> Enum.map(&visible_text/1)

    isbns = find_all_elements(:class, "pip_isbn")
      |> Enum.drop(1) 
      |> Enum.take_every(2) 
      |> Enum.map(&visible_text/1)
    
    calls = find_all_elements(:class, "pip_callNumber")
      |> Enum.drop(1) 
      |> Enum.take_every(2) 
      |> Enum.map(&visible_text/1)

    statuses = find_all_elements(:class, "pip_status")
      |> Enum.filter(fn(x) -> css_property(x, "display") != "none" end) 
      |> Enum.drop(2) 
      |> Enum.take_every(2)
      |> Enum.map(&visible_text/1) 
      
    numbers = find_all_elements(:class, "pip_barcode")
      |> Enum.drop(1) 
      |> Enum.take_every(2) 
      |> Enum.map(&visible_text/1)
    
    ats = find_all_elements(:class, "pip_branchName")
      |> Enum.drop(1) 
      |> Enum.take_every(2) 
      |> Enum.map(&visible_text/1)

    ons = find_all_elements(:class, "pip_date1")
      |> Enum.drop(1) 
      |> Enum.take_every(2) 
      |> Enum.map(&visible_text/1)



    Enum.with_index(authors)
    |> Enum.map(fn {a, i} ->
        %Loan{author: a,
          title: Enum.fetch!(titles, i),
          due: Enum.fetch!(dues, i),
          pub: Enum.fetch!(pubs, i),
          call: Enum.fetch!(calls, i),
          status: Enum.fetch!(statuses, i),
          number: Enum.fetch!(numbers, i),
          on: Enum.fetch!(ons, i),
          at: Enum.fetch!(ats, i),
          isbn: Enum.fetch!(isbns, i)
        }
      end)
  end
end
