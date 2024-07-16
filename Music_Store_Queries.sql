* Intermediate questions:*
1) */Senior most Employee based on job title?*/
  select top 1 title,first_name, last_name,levels
 from employee
 order by levels desc;

 2)/*Q2: Which countries have the most Invoices? */
  select count(*) as Count_of_Invoices,billing_country
  from invoice
  group by billing_country 
  order by Count_of_Invoices desc;

   
3)/* Q3: What are top 3 values of total invoice? */
select top 3 total
from invoice
order by total desc;

     
4)/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select 
top 1 sum(total) as Invoice_Total,
billing_city 
from invoice
group by billing_city
order by Invoice_Total desc;

 

5)/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select top 1 customers.customer_id, 
first_name,
last_name, 
sum(total) as Total_spending
from customers join invoice 
on customers.customer_id=invoice.customer_id
group by customers.customer_id, first_name,last_name
order by Total_spending desc;

 
 
 /* Question Set 2 - Moderate */*

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

Method-1:
*********
select distinct email,first_name,last_name
from customers
join invoice on customers.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_line_id
where track_id in(
              select track_id from track
			  join genre on track.genre_id=genre.genre_id
			  where genre.name like 'Rock')
			  order by email;
   
Method-2:
*********
SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customers
JOIN invoice ON invoice.customer_id = customers.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;



2) /* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
select top 10 artist.artist_id,artist.name, count(artist.artist_id) as Number_of_Songs
from track 
join album on album.album_id=track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id, artist.name
order by Number_of_Songs desc;
 
/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select name,milliseconds
from track
where milliseconds >(select avg(milliseconds) as AVerage_song_length
                     from track)
					 order by milliseconds desc;
   


     /* Question Set 3 - Advance */
/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */./* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price for each artist. */
with best_selling_artist as(
select top 1 artist.artist_id as artist_ID, artist.name as artist_name,sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by artist.artist_id, artist.name
order by 3 desc 
)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,sum(il.unit_price*il.quantity) as Amount_spent
from invoice i
join customers c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album a on a.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=a.artist_id
group by c.customer_id,c.first_name,c.last_name,bsa.artist_name
order by 5 desc;
   
/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */
with Popular_genre as(
select count(invoice_line.quantity) as Purchases,customers.country,genre.name, genre.genre_id,
ROW_NUMBER() OVER(PARTITION BY customers.country order by count(invoice_line.quantity) desc) as Row_Num
from invoice_line
join invoice on invoice.invoice_id=invoice_line.invoice_id
join customers on customers.customer_id=invoice.customer_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.genre_id
group by customers.country,genre.name, genre.genre_id)
SELECT * FROM Popular_genre WHERE Row_num <= 1
  

Q3:/* Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount.
Steps to Solve:  Similar to the above question. There are two parts in question- first find the most spent on music for each country and second filter the data for respective customers. */
with Customer_with_country AS 
( select customers.customer_id,first_name,last_name,billing_country,sum(total) as Total_Spending,
ROW_NUMBER() OVER(PARTITION BY billing_country order by sum(total) desc) as RowNum
from invoice 
join customers on customers.customer_id=invoice.customer_id
group by customers.customer_id,first_name,last_name,billing_country)
select * from Customer_with_country where RowNum <=1
order by Total_Spending desc;

  
