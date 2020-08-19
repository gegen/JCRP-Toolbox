import React, { useState } from 'react'
import Axios from 'axios'
import './App.css'
import './GetId.css'
import Mugshot from './Mugshot.png'
import Signature from './Signature.png'

export default function GetId({id, name}) {
    const [FN, setFN] = useState('')
    const [LN, setLN] = useState('')
    const [age, setAge] = useState('')
    const [inCad, setInCad] = useState(false)

    const SendReject = () => Axios.post('http://jcrp-toolbox/SendResponse', JSON.stringify({id: id, msg: `<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.11.1/css/all.css" integrity="sha384-IT8OQ5/IfeLGe8ZMxjj3QQNqT0zhBJSiFCL3uolrGgKRuenIU+mMS94kck/AHZWu" crossorigin="anonymous">
        <div font-weigth style="padding: 10px; background-color: rgba(100, 100, 100, 0.6); border-radius: 3px;">
            <i class="fas fa-address-card"></i>
            [{0}] {1}:<br>
            Did not provide an ID.
        </div>`
    }))

    const SendID = () => Axios.post('http://jcrp-toolbox/SendResponse', JSON.stringify({id: id, msg: `<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.11.1/css/all.css" integrity="sha384-IT8OQ5/IfeLGe8ZMxjj3QQNqT0zhBJSiFCL3uolrGgKRuenIU+mMS94kck/AHZWu" crossorigin="anonymous">
        <div font-weigth style="padding: 10px; background-color: rgba(100, 100, 100, 0.6); border-radius: 3px;">
            <i class="fas fa-address-card"></i>
            [{0}] {1}:<br />
            ${LN}, ${FN}<br/>
            Age: ${age}<br/>
            ${inCad ? 'Registered in CAD' : 'Not registered in CAD'}
        </div>`
    }))

    return (
        <div className='Container-Queue'>
            <div className='title'>{`[${id}] ${name} has asked for your ID.`}</div>
            <div className='innerContainer'>
                <div className='id-card'>
                    <div className='California'>California</div>
                    <div className='USA'>USA</div>
                    <div className='ID-top'>IDENTIFICATION</div>
                    <div className='ID-bottom'>CARD</div>
                    <div className='Line1' />
                    <div className='Line2' />
                    <img src={Mugshot} className='Mugshot' alt='' />
                    <img src={Signature} className='Signature' alt='' />
                    <div className='Inputs'>
                        <input value={FN} onChange={(e) => setFN(e.target.value)} placeholder='Firstname' autoFocus />
                        <input value={LN} onChange={(e) => setLN(e.target.value)} placeholder='Lastname' />
                        <input value={age} onChange={(e) => setAge(e.target.value)} placeholder='Age' style={{width: '60px'}} />
                    </div>
                </div>
                <div className="checkbox" style={{marginTop: '20px'}}>
                    <input value={inCad} onChange={(e) => setInCad(e.target.checked)} type="checkbox" id="box1" />
                    <label htmlFor="box1">Registered in CAD</label>
                </div>
                <div style={{marginTop: '20px'}}>
                    <button onClick={SendReject} className='outlinebtn'>Reject</button>
                    <button onClick={SendID} style={{marginLeft: '40px'}}>Hand ID</button>
                </div>
            </div>
        </div>
    )
}